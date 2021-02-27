class CreateFormKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :form_keys do |t|
      t.string :key_name
      t.string :conditions
      t.text :content
      t.timestamps
    end
  end
end
