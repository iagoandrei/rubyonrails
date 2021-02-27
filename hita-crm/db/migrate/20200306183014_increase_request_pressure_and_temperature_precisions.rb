class IncreaseRequestPressureAndTemperaturePrecisions < ActiveRecord::Migration[6.0]
  def change
    change_column :requests, :pressure_proj, :decimal, precision: 7, scale: 2
    change_column :requests, :pressure_opr, :decimal, precision: 7, scale: 2
    change_column :requests, :temperature_proj, :decimal, precision: 7, scale: 2
    change_column :requests, :temperature_opr, :decimal, precision: 7, scale: 2
  end
end
