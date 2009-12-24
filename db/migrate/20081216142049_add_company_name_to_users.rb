class AddCompanyNameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :company_name, :string
    
    User.transaction do
      User.find(:all, :include => :company).each do |u|
        u.company_name = u.company.name unless u.company.nil?
        u.save(false)
      end
    end
  end

  def self.down
    remove_column :users, :company_name
  end
end
