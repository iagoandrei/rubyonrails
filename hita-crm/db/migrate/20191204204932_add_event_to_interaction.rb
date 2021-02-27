class AddEventToInteraction < ActiveRecord::Migration[6.0]
  def change
    add_reference :interactions, :event, null: true
  end
end
