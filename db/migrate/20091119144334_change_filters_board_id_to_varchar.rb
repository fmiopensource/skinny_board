class ChangeFiltersBoardIdToVarchar < ActiveRecord::Migration
  def self.up
    change_column :user_board_filters, :board_id, :string
  end

  def self.down
    change_column :user_board_filters, :board_id, :integer
  end
end
