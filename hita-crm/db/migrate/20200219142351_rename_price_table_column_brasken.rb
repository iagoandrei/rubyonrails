class RenamePriceTableColumnBrasken < ActiveRecord::Migration[6.0]
  def change
    rename_column :products, :brasken_price, :braskem_price
    rename_column :products, :brasken_sp_price, :braskem_sp_price
  end
end
