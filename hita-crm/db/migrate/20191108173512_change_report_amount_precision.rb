class ChangeReportAmountPrecision < ActiveRecord::Migration[6.0]
  def change
    change_column :reports, :amount, :decimal, :precision => 15, :scale => 2
  end
end
