class AddCampaignIdToPost < ActiveRecord::Migration
  def change
    add_column :posts, :campaign_id, :integer
  end
end
