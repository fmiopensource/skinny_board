class AddOwnerToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :owner_id, :integer
  end

  def self.down
    remove_column :companies, :owner_id
  end
end
