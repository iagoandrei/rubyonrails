class AddCodeAndUnitToProducts < ActiveRecord::Migration[6.0]
  def change
  	add_column :products, :code, :string
  	add_column :products, :unit, :string
  end
end
