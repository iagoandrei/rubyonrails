class ImprovesRequestAndEquipmentModels < ActiveRecord::Migration[6.0]
  def change
  	add_column :requests, :is_stock_replacement, :boolean
  	add_column :requests, :equipment_sizes, :text

    add_reference :requests, :collaborator
  	add_reference :requests, :equipment

  	remove_column :equipments, :size_1, :string
  	remove_column :equipments, :size_2, :string
  	remove_column :equipments, :size_3, :string
  	remove_column :equipments, :size_4, :string
  	remove_column :equipments, :size_5, :string
  	remove_column :equipments, :size_6, :string
  	remove_column :equipments, :size_7, :string
  	remove_column :equipments, :size_8, :string
  	remove_column :equipments, :size_9, :string
  	remove_column :equipments, :size_10, :string
  end
end
