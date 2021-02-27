class RemoveChargeInInstallments < ActiveRecord::Migration[6.0]
  def change
  	remove_column :requests, :charge_in_installments, :boolean
  end
end
