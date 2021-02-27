class AddObservationToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :observation, :text
  end
end
