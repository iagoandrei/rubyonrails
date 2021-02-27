class CreateForm < ActiveRecord::Migration[6.0]
  def change
    create_table :forms do |t|
      t.string :name
      t.timestamps
    end
  end
end
