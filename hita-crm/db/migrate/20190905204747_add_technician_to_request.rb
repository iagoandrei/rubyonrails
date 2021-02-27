class AddTechnicianToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :technician_id, :bigint
  end
end
