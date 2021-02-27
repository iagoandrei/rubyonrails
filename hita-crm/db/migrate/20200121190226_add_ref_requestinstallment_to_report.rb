class AddRefRequestinstallmentToReport < ActiveRecord::Migration[6.0]
  def change
    add_reference :reports, :request_installment, index: true
  end
end
