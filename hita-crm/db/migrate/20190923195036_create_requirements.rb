class CreateRequirements < ActiveRecord::Migration[6.0]
  def change
    create_table :requirements do |t|
      t.string :title
      t.string :requirement_type
      t.string :input

      t.timestamps
    end
  end
end
