class AddRequestToInteractions < ActiveRecord::Migration[6.0]
  def change
    add_reference :interactions, :request, null: true
  end
end
