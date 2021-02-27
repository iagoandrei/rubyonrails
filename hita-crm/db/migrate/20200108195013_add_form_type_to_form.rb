class AddFormTypeToForm < ActiveRecord::Migration[6.0]
  def change
    add_column :forms, :form_type, :string
  end
end
