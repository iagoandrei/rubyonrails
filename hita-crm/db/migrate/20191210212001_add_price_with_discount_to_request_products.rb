class AddPriceWithDiscountToRequestProducts < ActiveRecord::Migration[6.0]
  def change
  	add_column :request_products, :price_with_discount, :decimal, precision: 12, scale: 2, default: 0
  end
end
