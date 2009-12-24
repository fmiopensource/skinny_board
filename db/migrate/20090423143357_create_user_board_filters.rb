class CreateUserBoardFilters < ActiveRecord::Migration
  def self.up
    create_table :user_board_filters do |t|
      t.column :user_id,  :integer, :references => :users,    :null => false
      t.column :board_id, :integer, :references => :elements, :null => false
      t.string :filters
    end
  end

  def self.down
    drop_table :user_board_filters
  end
end
