class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name, :limit => 100
      t.string :basecamp_id
      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end
