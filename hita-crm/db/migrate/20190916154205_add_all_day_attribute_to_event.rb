class AddAllDayAttributeToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :is_all_day, :boolean
  end
end
