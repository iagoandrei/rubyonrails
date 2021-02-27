class CreateEquipments < ActiveRecord::Migration[6.0]
  def change
    create_table :equipments do |t|
      t.string :name
      t.text :questions
    end
  end
end
