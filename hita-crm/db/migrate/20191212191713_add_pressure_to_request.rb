class AddPressureToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :pressure, :text
  end
end
