class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :description
      t.string :status
      t.string :priority

      t.timestamps
    end
  end
end
