class CreateJoinTableProductsRequests < ActiveRecord::Migration[6.0]
  def change
    create_join_table :products, :requests do |t|
      t.index [:product_id, :request_id]
      t.index [:request_id, :product_id]
    end
  end
end
