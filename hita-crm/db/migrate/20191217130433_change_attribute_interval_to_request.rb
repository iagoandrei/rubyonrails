class ChangeAttributeIntervalToRequest < ActiveRecord::Migration[6.0]
  def self.up
    change_column :requests, :pressure, :decimal, using: 'pressure::numeric'
    change_column :requests, :temperature, :decimal, using: 'temperature::numeric'
  end

  def self.down
    change_column :requests, :pressure, :decimal, using: 'pressure::numeric'
    change_column :requests, :temperature, :decimal, using: 'temperature::numeric'
  end
end
