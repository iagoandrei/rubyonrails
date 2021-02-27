class AddRequestToReport < ActiveRecord::Migration[6.0]
  def change
    add_reference :reports, :request, null: true
  end
end
