class CreateRequestConditions < ActiveRecord::Migration[6.0]
  def change
    create_table :request_conditions do |t|
      t.string :payment_type
      t.string :operation_type
      t.string :storage_center
      t.string :payment_code
      t.references :request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
