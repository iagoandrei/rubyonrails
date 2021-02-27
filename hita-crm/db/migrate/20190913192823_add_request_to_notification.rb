class AddRequestToNotification < ActiveRecord::Migration[6.0]
  def change
    add_reference :notifications, :request, null: true
  end
end
