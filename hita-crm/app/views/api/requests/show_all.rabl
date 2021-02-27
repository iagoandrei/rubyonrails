collection @requests
attributes :id, :enterprise_id, :collaborator_id, :equipment_id, :is_stock_replacement, :is_draft,
		   :request_type, :response_time, :shipping_modality, :shipping_type, :value_estimation,
		   :request_code
attributes get_request_quiz_data: :quiz_data
attributes get_request_code: :request_code
attributes request_products_for_api: :request_products
attributes equipment_sizes: :equipment_measures
