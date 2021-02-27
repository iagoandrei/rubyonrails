class AddProductToReport < ActiveRecord::Migration[6.0]
  def change
    add_reference :reports, :product, null: true
  end
end
