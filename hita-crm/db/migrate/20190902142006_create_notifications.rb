class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.string :title
      t.string :message
      t.boolean :read, default: false
      t.datetime :schedule_date, null: true
      t.references :user, null: true
      t.references :collaborator, null: true
      t.references :enterprise, null: true
      t.references :interaction, null: true
      t.references :event, null: true

      t.timestamps
    end
  end
end
