class AddOwnerToInteraction < ActiveRecord::Migration[6.0]
  def change
    add_reference :interactions, :owner, null: true
  end
end
