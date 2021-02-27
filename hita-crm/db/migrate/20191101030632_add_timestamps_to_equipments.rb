class AddTimestampsToEquipments < ActiveRecord::Migration[6.0]
  def change
  	add_column :equipments, :created_at, :datetime, null: false
  	add_column :equipments, :updated_at, :datetime, null: false
  end
end
