class IncreaseFormKeyConditionsSize < ActiveRecord::Migration[6.0]
  def up
    change_column :form_keys, :conditions, :text
  end
  def down
    change_column :form_keys, :conditions, :string
  end
end
