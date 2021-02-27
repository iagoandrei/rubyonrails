class AddIsActiveToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :is_active, :boolean, default: true
  end
end
