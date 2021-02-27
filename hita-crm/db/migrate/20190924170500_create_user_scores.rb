class CreateUserScores < ActiveRecord::Migration[6.0]
  def change
    create_table :user_scores do |t|
      t.date :period
      t.string :level
      t.string :comment
      t.integer :quantity
      t.decimal :value, :precision => 8, :scale => 2
      t.decimal :score, :precision => 8, :scale => 2
      t.references :requirement, null: false
      t.references :user, null: false

      t.timestamps
    end
  end
end
