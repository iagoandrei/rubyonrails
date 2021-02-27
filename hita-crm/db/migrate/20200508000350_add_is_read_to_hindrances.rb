class AddIsReadToHindrances < ActiveRecord::Migration[6.0]
  def change
    add_column :hindrances, :is_read, :boolean, default: :false
  end
end
