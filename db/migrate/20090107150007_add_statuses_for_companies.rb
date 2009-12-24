class AddStatusesForCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :company_status_id, :integer, :default => 1
    
    create_table :company_statuses do |t|
      t.string :name
      t.timestamps
    end
    
    CompanyStatus.create(:id => 1, :name => 'Active')
    CompanyStatus.create(:id => 2, :name => 'Canceled')
    CompanyStatus.create(:id => 3, :name => 'Suspended')
    
  end

  def self.down
    remove_column :companies, :company_status_id
    
    drop_table :company_statuses
  end
end
