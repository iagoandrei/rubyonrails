class AddRequestCodeToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :request_code, :bigint
  end
end
