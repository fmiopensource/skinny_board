class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :deleted_at,                :datetime

      t.string  :first_name, :limit => 40
      t.string  :last_name,  :limit => 40
      t.string  :avatar_url
      t.column :twitter_login,                     :string
      t.column :twitter_password,                     :string
      t.belongs_to :company
      
      t.timestamps
    end
  end

  def self.down
    drop_table "users"
  end
end
