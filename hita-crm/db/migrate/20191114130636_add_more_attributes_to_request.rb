class AddMoreAttributesToRequest < ActiveRecord::Migration[6.0]
  def change
  	add_column :requests, :cause_or_reason, :text
  	add_column :requests, :temperature, :text
  	add_column :requests, :solutions, :text
  	add_column :requests, :substratum, :text
  	add_column :requests, :surface_preparation, :text
  	add_column :requests, :fluids, :text
  end
end
