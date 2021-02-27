class AddIsBilledToRequest < ActiveRecord::Migration[6.0]
  def change
  	add_column :requests, :is_billed, :boolean, default: false
  end
end
