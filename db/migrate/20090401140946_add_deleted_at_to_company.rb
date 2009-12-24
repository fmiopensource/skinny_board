class AddDeletedAtToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :deleted_at, :datetime
  end

  def self.down
    remove_column :companies, :deleted_at
  end
end
