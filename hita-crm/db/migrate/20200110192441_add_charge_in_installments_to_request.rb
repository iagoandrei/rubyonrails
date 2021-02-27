class AddChargeInInstallmentsToRequest < ActiveRecord::Migration[6.0]
  def change
  	add_column :requests, :charge_in_installments, :boolean, default: false
  end
end
