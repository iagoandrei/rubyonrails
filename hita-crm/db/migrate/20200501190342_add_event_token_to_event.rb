class AddEventTokenToEvent < ActiveRecord::Migration[6.0]
  def change
  	add_column :events, :event_token, :string
  end
end
