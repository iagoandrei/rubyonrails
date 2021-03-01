class CreateCommissions < ActiveRecord::Migration[6.0]
  def change
    create_table :commissions do |t|
      t.string :represent
      t.string :value
      t.string :paydate
      t.string :paid
      t.references :request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
