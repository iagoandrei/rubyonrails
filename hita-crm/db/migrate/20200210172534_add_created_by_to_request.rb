class AddCreatedByToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :created_by_id, :bigint
  end
end
