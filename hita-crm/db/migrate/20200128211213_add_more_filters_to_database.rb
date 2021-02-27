class AddMoreFiltersToDatabase < ActiveRecord::Migration[6.0]
  def change
    remove_column :requests, :temperature
    remove_column :requests, :pressure

    add_column :requests, :pressure_proj, :decimal, precision: 5, scale: 2
    add_column :requests, :pressure_opr, :decimal, precision: 5, scale: 2

    add_column :requests, :temperature_proj, :decimal, precision: 5, scale: 2
    add_column :requests, :temperature_opr, :decimal, precision: 5, scale: 2
  end
end
