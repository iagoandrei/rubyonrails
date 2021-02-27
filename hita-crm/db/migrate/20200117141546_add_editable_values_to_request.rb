class AddEditableValuesToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :real_loose_value, :decimal, precision: 15, scale: 2, default: 0
    add_column :requests, :planned_loose_value, :decimal, precision: 15, scale: 2, default: 0
    add_column :requests, :planned_products_value, :decimal, precision: 15, scale: 2, default: 0
    add_column :requests, :planned_service_value, :decimal, precision: 15, scale: 2, default: 0
    add_column :requests, :planned_request_value, :decimal, precision: 15, scale: 2, default: 0
  end
end
