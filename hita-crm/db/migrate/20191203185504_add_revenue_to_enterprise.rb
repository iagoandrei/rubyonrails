class AddRevenueToEnterprise < ActiveRecord::Migration[6.0]
  def change
    add_column :enterprises, :revenue, :decimal, :precision => 15, :scale => 2, :default => 0
  end
end
