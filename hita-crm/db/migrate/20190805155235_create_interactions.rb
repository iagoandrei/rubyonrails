class CreateInteractions < ActiveRecord::Migration[6.0]
  def change
    create_table :interactions do |t|
      t.string :interaction_type
      t.string :content
      t.integer :score
      t.references :collaborator, null: true
      t.references :enterprise, null: true
      t.references :user, null: true

      t.timestamps
    end
  end
end
