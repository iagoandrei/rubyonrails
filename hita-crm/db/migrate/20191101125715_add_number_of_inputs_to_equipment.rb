class AddNumberOfInputsToEquipment < ActiveRecord::Migration[6.0]
  def change
    add_column :equipments, :number_of_inputs, :integer, limit: 1
  end
end
