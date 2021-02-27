json.extract! request_condition, :id, :payment_type, :operation_type, :storage_center, :payment_code, :request_id, :created_at, :updated_at
json.url request_condition_url(request_condition, format: :json)
