class CreateRequestProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :request_products do |t|
    	t.integer :product_quantity
    end

    add_reference :request_products, :request
    add_reference :request_products, :product
  end
end
