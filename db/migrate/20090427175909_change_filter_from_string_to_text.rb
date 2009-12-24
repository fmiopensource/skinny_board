class ChangeFilterFromStringToText < ActiveRecord::Migration
  def self.up
    change_column :user_board_filters, :filters, :text
  end

  def self.down
  end
end
