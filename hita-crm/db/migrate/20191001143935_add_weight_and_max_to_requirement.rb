class AddWeightAndMaxToRequirement < ActiveRecord::Migration[6.0]
  def change
    add_column :requirements, :weight, :decimal, :precision => 8, :scale => 2
    add_column :requirements, :max, :decimal, :precision => 8, :scale => 2
  end
end
