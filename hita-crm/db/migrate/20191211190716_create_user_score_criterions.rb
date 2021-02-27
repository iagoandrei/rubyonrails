class CreateUserScoreCriterions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_score_criterions do |t|
      t.integer :criterion_type
      t.boolean :status
      t.integer :year
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
