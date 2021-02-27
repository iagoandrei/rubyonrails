class AddDueTimeToHindrances < ActiveRecord::Migration[6.0]
  def change
    add_column :hindrances, :due_time, :date
  end
end
