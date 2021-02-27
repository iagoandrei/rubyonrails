class AddIsActiveAndIpiToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :is_active, :boolean, default: true
    add_column :products, :ipi, :decimal, precision: 5, scale: 2 , default: 0
  end
end
