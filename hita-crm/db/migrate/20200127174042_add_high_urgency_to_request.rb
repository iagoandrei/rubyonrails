class AddHighUrgencyToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :high_urgency, :boolean, default: false
  end
end
