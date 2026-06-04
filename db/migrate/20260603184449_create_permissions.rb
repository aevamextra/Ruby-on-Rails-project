class CreatePermissions < ActiveRecord::Migration[8.1]
  def change
    create_table :permissions do |t|
      t.string :name
      t.string :description
      t.string :resource
      t.string :action

      t.timestamps
    end
  end
end
