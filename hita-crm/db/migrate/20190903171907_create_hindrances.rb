class CreateHindrances < ActiveRecord::Migration[6.0]
  def change
    create_table :hindrances do |t|
      t.boolean :is_active
      t.timestamps
    end

    add_column :hindrances, :user_id, :bigint
    add_column :hindrances, :created_by, :bigint
    add_reference :hindrances, :request
  end
end
