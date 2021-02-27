class AddTimestampsToEnterprise < ActiveRecord::Migration[6.0]
  def change
    unless column_exists? :enterprises, :created_at
      add_column :enterprises, :created_at, :datetime, null: false, default: DateTime.current
    end
    unless column_exists? :enterprises, :updated_at
      add_column :enterprises, :updated_at, :datetime, null: false, default: DateTime.current
    end
  end
end
