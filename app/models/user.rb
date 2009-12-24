require 'digest/sha1'
require 'RMagick'
class User < ActiveRecord::Base
  acts_as_paranoid
  
  # Virtual attribute for the unencrypted password
  attr_accessor   :password, :reset_password, :forgotten_password, :terms_of_service
  cattr_accessor :current_user

  belongs_to :company
  has_many :user_board_filters

  validates_presence_of     :login, :email, :first_name, :last_name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?, :allow_blank => true
  validates_confirmation_of :password,                   :if => :password_required?, :allow_blank => true
  validates_length_of       :login,    :within => 3..40,  :allow_blank => true
  validates_length_of       :email,    :within => 3..100, :allow_blank => true
  validates_format_of       :email,    :with => /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, :allow_blank => true
  validates_uniqueness_of   :login, :case_sensitive => false, :scope => [:company_id]
  validates_uniqueness_of   :email, :case_sensitive => false, :allow_blank => true, :unless => :skip_on_cancel, :scope => [:company_id]
  validates_acceptance_of   :terms_of_service

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password, company_id) 
    # hide records with a nil activated_at 
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL and company_id = ?', login, company_id] 
    u && u.authenticated?(password) ? u : nil
  end
  
  def subdomain
    company.nil? ? "" : company.subdomain.downcase
  end
  
  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end
  
  def reset_password(password = nil, password_confirmation = nil)
    update_attributes(:password_reset_code => nil, :crypted_password => nil, :password => password, :password_confirmation => password_confirmation)
    @reset_password = valid? ? true : false
  end

  def activate 
    @activated = true 
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil) 
  end

  def recently_activated? 
    @activated 
  end
  
  def recently_reset_password?
    @reset_password
  end
  
  def recently_forgot_password?
    @forgotten_password 
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def full_name
    [self.first_name, self.last_name].compact.join(" ")
  end
  

  def self.random_password
    String.random
  end  
  
  def avatar
    self.avatar_url.blank? ? DEFAULT_AVATAR : self.avatar_url
  end
  
  def is_invited?
    !(self.invited_code.nil? or self.invited_code.empty?)
  end
  
  def is_company_owner?(element_id)
    val = false
    
    # Ensure this user is the owner of their company
    if self.company and (self.id == self.company.owner_id)
      # Ensure it's the right company
      e = Element.find(element_id)
      e = e[0] if (e.is_a?(Array))
      val = (self.company_id == e.creator.company_id)
    end
    # val
    true
  end
  
  def validate_invite_code(to_validate = nil)
    (self.invited_code == to_validate)
  end
  
  def skip_on_cancel
    email.eql?("cancelled@skinnyboard.com") ? true : false
  end
  
  def generate_invite_code
    self.invited_code = random_hex
  end
  
  def upload_avatar(avatar_file, remove_image = false)
    url = nil
    unless remove_image
      return if avatar_file.blank?
      file_name = "user-#{self.id}-#{self.created_at.to_i}.#{/(.*\.)(.*$)/.match(avatar_file.original_filename)[2]}"

      avatar_image = thumbnailify(avatar_file)
      avatar_image.write("public/images/#{file_name}")
      S3Interface.save_to_s3("public/images/#{file_name}", "avatars/#{file_name}")

      FileUtils.rm("public/images/#{file_name}")

      url = S3Interface.retrieve_from_s3("avatars/#{file_name}")
      url.gsub!(/^http:/, 'https:') unless url.nil?
    end

    self.update_attribute(:avatar_url, url)
  end
  
  def self.users_for_board(board_id)
    users = User.find(:all,
          :conditions => ["permissions.element_id = ?", board_id],
          :include => :permissions )
    unless users.blank?
      users += [users.first.company.owner] unless (users.first.company.nil? or users.first.company.owner.nil?)
      users.sort!{|a, b| a.first_name.downcase <=> b.first_name.downcase}
      users.uniq!
    end
    users
  end
  
  def sanitize
    # email can't be scrambled to meet validator constraints
    passwrd = 'password'.random_string
    self.update_attributes!(:login => 'login'.random_string,
                            :password => passwrd,
                            :password_confirmation => passwrd,
                            :email => "cancelled@skinnyboard.com",
                            :first_name => "Deleted",
                            :last_name => "User")
  end
  
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record? or salt.blank?
    self.crypted_password = encrypt(password)
  end

  def make_activation_code
    self.activation_code = random_hex
  end

protected

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def make_password_reset_code
    self.password_reset_code = random_hex
  end
     
private

  def random_hex
    Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def thumbnailify(file)
    #read the image from the string
    imgs = Magick::Image.from_blob(file.read)

    #change the geometry of the image to suit our predefined size
    avatar_image = imgs.first.change_geometry!("48x48") do |cols, rows, image|
      #if the cols or rows are smaller then our predefined sizes we build a white background and center the image in it
      if cols < 48 || rows < 48
        #resize our image
        image.resize!(cols, rows)
        #build the white background
        bg = Magick::Image.new(48,48){self.background_color = "white"}

        #center the image on our new white background
        bg.composite(image, Magick::CenterGravity, Magick::OverCompositeOp)
      else
        #in the unlikely event that the new geometry cols and rows match our predefined size we will not set a white bg
        image.resize!(cols, rows)
      end
    end

    return avatar_image
  end
end
