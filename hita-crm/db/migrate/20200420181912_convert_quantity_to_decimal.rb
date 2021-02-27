class ConvertQuantityToDecimal < ActiveRecord::Migration[6.0]
  def self.up
    change_column :request_products, :product_quantity, :decimal, scale: 2, precision: 15
  end

  def self.down
    change_column :request_products, :product_quantity, :integer
  end
end
