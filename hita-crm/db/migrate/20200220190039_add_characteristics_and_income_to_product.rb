class AddCharacteristicsAndIncomeToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :income, :string
    add_column :products, :characteristics, :text
  end
end
