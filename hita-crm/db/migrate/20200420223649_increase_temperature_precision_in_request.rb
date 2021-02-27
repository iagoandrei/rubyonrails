class IncreaseTemperaturePrecisionInRequest < ActiveRecord::Migration[6.0]
  def self.up
    change_column :requests, :temperature_proj, :decimal, scale: 2, precision: 15
    change_column :requests, :temperature_opr, :decimal, scale: 2, precision: 15
  end

  def self.down
    change_column :requests, :temperature_proj, :decimal, scale: 2, precision: 7
    change_column :requests, :temperature_opr, :decimal, scale: 2, precision: 7
  end
end
