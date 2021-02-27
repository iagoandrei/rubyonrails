class AddSizesAndPhotosToEquipments < ActiveRecord::Migration[6.0]
  def change
    add_column :equipments, :size_1, :string
    add_column :equipments, :size_2, :string
    add_column :equipments, :size_3, :string
    add_column :equipments, :size_4, :string
    add_column :equipments, :size_5, :string
    add_column :equipments, :size_6, :string
    add_column :equipments, :size_7, :string
    add_column :equipments, :size_8, :string
    add_column :equipments, :size_9, :string
    add_column :equipments, :size_10, :string
  end
end
