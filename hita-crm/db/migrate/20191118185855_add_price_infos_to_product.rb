class AddPriceInfosToProduct < ActiveRecord::Migration[6.0]
  def change
  	add_column :products, :dollar_price, :decimal, precision: 10, scale: 2, default: 0
  	add_column :products, :current_dollar_price, :decimal, precision: 10, scale: 2
  	add_column :products, :fob_price, :decimal, precision: 10, scale: 2
  	add_column :products, :brasken_price, :decimal, precision: 10, scale: 2
  	add_column :products, :brasken_sp_price, :decimal, precision: 10, scale: 2
  	add_column :products, :yara_price, :string, default: ''
  	add_column :products, :mosaic_price, :decimal, precision: 10, scale: 2
  	add_column :products, :vale_mining_price, :decimal, precision: 10, scale: 2
  	add_column :products, :anglo_american_price, :decimal, precision: 10, scale: 2
  	add_column :products, :ancellor_price, :decimal, precision: 10, scale: 2
  	add_column :products, :modec_price, :decimal, precision: 10, scale: 2
  	add_column :products, :petrobras_price, :decimal, precision: 10, scale: 2
  end
end
