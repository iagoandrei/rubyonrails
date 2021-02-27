class CreateRequestInstallment < ActiveRecord::Migration[6.0]
  def change
    create_table :request_installments do |t|
      t.decimal :value, :precision => 15, :scale => 2
      t.date :date
      t.boolean :is_billed, default: false
      t.boolean :is_paid, default: false

      t.references :request, null: false
    end
  end
end
