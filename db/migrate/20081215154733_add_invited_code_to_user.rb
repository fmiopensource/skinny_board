class AddInvitedCodeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :invited_code, :string
  end

  def self.down
    remove_column :users, :invited_code
  end
end
