class AddIsValidToRequests < ActiveRecord::Migration[6.0]
  def change
  	add_column :requests, :is_valid, :boolean, default: false
  end
end
