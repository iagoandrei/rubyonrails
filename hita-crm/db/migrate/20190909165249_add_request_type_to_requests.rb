class AddRequestTypeToRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :request_type, :string
  end
end
