class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :subject
      t.datetime :scheduled_at
      t.integer :sendinblue_id

      t.timestamps null: false
    end
  end
end
