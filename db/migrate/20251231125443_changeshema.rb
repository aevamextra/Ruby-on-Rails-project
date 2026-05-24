class Changeshema < ActiveRecord::Migration[8.1]
  def change
    change_column :tasks, :title, :string, null: false
    change_column :tasks, :description, :string, null: false
  end
end
