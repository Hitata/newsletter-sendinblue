class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.string :company_name
      t.boolean :featured
      t.integer :entry_id
      t.integer :salary
      t.text :logo_url

      t.timestamps null: false
    end
  end
end
