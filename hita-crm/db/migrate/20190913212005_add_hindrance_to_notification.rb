class AddHindranceToNotification < ActiveRecord::Migration[6.0]
  def change
    add_reference :notifications, :hindrance, null: true
  end
end
