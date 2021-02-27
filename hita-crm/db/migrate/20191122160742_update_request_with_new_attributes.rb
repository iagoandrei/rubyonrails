class UpdateRequestWithNewAttributes < ActiveRecord::Migration[6.0]
  def change
  	add_column :requests, :response_time, :date
  	add_column :requests, :shipping_type, :string
  	add_column :requests, :value_estimation, :decimal, precision: 12, scale: 2, default: 0
  	add_column :requests, :calculated_revenue, :decimal, precision: 15, scale: 2, default: 0

  	add_column :request_products, :shipping_price, :decimal, precision: 12, scale: 2, default: 0
  	add_column :request_products, :calculated_price, :decimal, precision: 15, scale: 2, default: 0
  end
end
