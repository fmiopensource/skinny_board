class AddSubdomainToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :subdomain, :string
  end

  def self.down
    remove_column :companies, :subdomain
  end
end
