class CreateReports < ActiveRecord::Migration[6.0]
  def change
    create_table :reports do |t|
      t.decimal :amount, :precision => 10, :scale => 2
      t.string :planning
      t.date :period
      t.references :enterprise, null: true

      t.timestamps
    end
  end
end
