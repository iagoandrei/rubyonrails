class AddUsersFlagToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :has_consultant, :boolean, :default => false
    add_column :events, :has_technician, :boolean, :default => false
    add_column :events, :has_technical_manager, :boolean, :default => false
  end
end
