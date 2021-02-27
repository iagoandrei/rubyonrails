class AddNcmToProducts < ActiveRecord::Migration[6.0]
  def change
  	add_column :products, :ncm, :decimal, precision: 15, scale: 1
  end
end
