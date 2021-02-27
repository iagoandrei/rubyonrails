class AddPriceTableToEnterprise < ActiveRecord::Migration[6.0]
  def change
  	add_column :enterprises, :price_table, :string
  end
end
