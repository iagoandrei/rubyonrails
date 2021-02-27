class AddRequestTypeToInteractions < ActiveRecord::Migration[6.0]
  def change
    add_column :interactions, :request_type, :string
  end
end
