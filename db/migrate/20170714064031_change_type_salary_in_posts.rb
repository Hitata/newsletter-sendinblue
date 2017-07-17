class ChangeTypeSalaryInPosts < ActiveRecord::Migration
  def change
    change_column :posts, :salary, :string
  end
end
