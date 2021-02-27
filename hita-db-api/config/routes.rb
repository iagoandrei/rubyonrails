Rails.application.routes.draw do
  root to: "application#not_found"
  match 'api/get_available_products/(:product_type)' => "stock#get_curent_products", via: :get, as: :get_available_products
  match 'api/product_complete_infos/' => "stock#product_complete_infos", via: :get, as: :product_complete_infos
  match 'api/products_by_code/:code' => "stock#product_by_code", via: :get, as: :get_product_by_code
end
