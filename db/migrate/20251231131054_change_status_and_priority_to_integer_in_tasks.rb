class ChangeStatusAndPriorityToIntegerInTasks < ActiveRecord::Migration[8.1]
  def change
    # SQLite cannot cast automatically — so we manually reset the columns
    remove_column :tasks, :status
    remove_column :tasks, :priority

    add_column :tasks, :status, :integer, default: 0
    add_column :tasks, :priority, :integer, default: 1
  end
end
