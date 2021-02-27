class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :title
      t.string :event_type
      t.datetime :period
      t.string :street
      t.references :enterprise, null: true

      t.timestamps
    end
  end
end
