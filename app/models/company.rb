class Company < ActiveRecord::Base
  acts_as_paranoid
  
  # Virtual Attributes
  attr_accessor_with_default :domain_changed, false
  
  has_many :users
  belongs_to :owner, :class_name => "User", :foreign_key => 'owner_id'
  has_one :company_status
  
  validates_presence_of :name, :message => "Company name can't be blank"
  validates_uniqueness_of :subdomain, :message => 'Subdomain already in use'
  validates_format_of :subdomain, :with => /^[a-z0-9_-]{1,255}$/, :allow_blank => true,
    :message => 'can contain only lowercase letters, digits, - and _'
  validates_presence_of :subdomain
  
end