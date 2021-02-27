class AddOwnerToEvents < ActiveRecord::Migration[6.0]
  def change
    add_reference :events, :owner, null: true
  end
end
