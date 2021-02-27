class AddRequestTypeToEquipments < ActiveRecord::Migration[6.0]
  def change
  	add_column :equipments, :is_for_product, :boolean
  	add_column :equipments, :is_for_service, :boolean
  end
end
