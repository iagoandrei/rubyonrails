class RenamePriceTableColumnAncellor < ActiveRecord::Migration[6.0]
  def change
    rename_column :products, :ancellor_price, :arcelor_price
  end
end
