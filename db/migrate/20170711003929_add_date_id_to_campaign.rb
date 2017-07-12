class AddDateIdToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :date_id, :string 
  end
end
