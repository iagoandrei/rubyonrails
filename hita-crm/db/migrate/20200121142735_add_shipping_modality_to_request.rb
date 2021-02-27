class AddShippingModalityToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :shipping_modality, :string
  end
end
