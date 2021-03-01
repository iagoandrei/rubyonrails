# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_08_132738) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "collaborators", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone_area"
    t.string "phone"
    t.string "job_role"
    t.string "degree_of_relationship"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "enterprise_id"
    t.integer "status"
    t.string "trained"
    t.string "area"
    t.index ["enterprise_id"], name: "index_collaborators_on_enterprise_id"
  end

  create_table "commissions", force: :cascade do |t|
    t.string "represent"
    t.string "value"
    t.string "paydate"
    t.string "paid"
    t.bigint "request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["request_id"], name: "index_commissions_on_request_id"
  end

  create_table "enterprises", force: :cascade do |t|
    t.string "name"
    t.string "industry_sector"
    t.string "enterprise_type"
    t.string "cep"
    t.string "city"
    t.string "state"
    t.string "address"
    t.string "business_name"
    t.string "cnpj"
    t.string "latitude"
    t.string "longitude"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.string "price_table"
    t.decimal "revenue", precision: 15, scale: 2, default: "0.0"
    t.index ["user_id"], name: "index_enterprises_on_user_id"
  end

  create_table "equipments", force: :cascade do |t|
    t.string "name"
    t.text "questions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number_of_inputs", limit: 2
    t.boolean "is_for_product"
    t.boolean "is_for_service"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "event_type"
    t.datetime "period"
    t.string "street"
    t.bigint "enterprise_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 1
    t.bigint "owner_id"
    t.boolean "is_all_day"
    t.boolean "has_consultant", default: false
    t.boolean "has_technician", default: false
    t.boolean "has_technical_manager", default: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "event_token"
    t.index ["enterprise_id"], name: "index_events_on_enterprise_id"
    t.index ["owner_id"], name: "index_events_on_owner_id"
  end

  create_table "events_users", id: false, force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "user_id", null: false
    t.index ["event_id", "user_id"], name: "index_events_users_on_event_id_and_user_id"
    t.index ["user_id", "event_id"], name: "index_events_users_on_user_id_and_event_id"
  end

  create_table "form_keys", force: :cascade do |t|
    t.string "key_name"
    t.text "conditions"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "request_quizzes_id"
    t.boolean "is_answer_printable", default: false
    t.text "answers_to_print"
    t.index ["request_quizzes_id"], name: "index_form_keys_on_request_quizzes_id"
  end

  create_table "forms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "form_type"
  end

  create_table "hindrances", force: :cascade do |t|
    t.boolean "is_active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "created_by"
    t.bigint "request_id"
    t.date "due_time"
    t.boolean "is_read", default: false
    t.index ["request_id"], name: "index_hindrances_on_request_id"
  end

  create_table "interactions", force: :cascade do |t|
    t.string "interaction_type"
    t.string "content"
    t.integer "score"
    t.bigint "collaborator_id"
    t.bigint "enterprise_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "enterprise_changed_old"
    t.bigint "enterprise_changed_new"
    t.datetime "interaction_date"
    t.bigint "owner_id"
    t.bigint "request_id"
    t.string "request_type"
    t.bigint "event_id"
    t.index ["collaborator_id"], name: "index_interactions_on_collaborator_id"
    t.index ["enterprise_id"], name: "index_interactions_on_enterprise_id"
    t.index ["event_id"], name: "index_interactions_on_event_id"
    t.index ["owner_id"], name: "index_interactions_on_owner_id"
    t.index ["request_id"], name: "index_interactions_on_request_id"
    t.index ["user_id"], name: "index_interactions_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "title"
    t.string "message"
    t.boolean "read", default: false
    t.datetime "schedule_date"
    t.bigint "user_id"
    t.bigint "collaborator_id"
    t.bigint "enterprise_id"
    t.bigint "interaction_id"
    t.bigint "event_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "request_id"
    t.bigint "hindrance_id"
    t.index ["collaborator_id"], name: "index_notifications_on_collaborator_id"
    t.index ["enterprise_id"], name: "index_notifications_on_enterprise_id"
    t.index ["event_id"], name: "index_notifications_on_event_id"
    t.index ["hindrance_id"], name: "index_notifications_on_hindrance_id"
    t.index ["interaction_id"], name: "index_notifications_on_interaction_id"
    t.index ["request_id"], name: "index_notifications_on_request_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.string "product_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "dollar_price", precision: 10, scale: 2, default: "0.0"
    t.decimal "current_dollar_price", precision: 10, scale: 2
    t.decimal "fob_price", precision: 10, scale: 2
    t.decimal "braskem_price", precision: 10, scale: 2
    t.decimal "braskem_sp_price", precision: 10, scale: 2
    t.string "yara_price", default: ""
    t.decimal "mosaic_price", precision: 10, scale: 2
    t.decimal "vale_mining_price", precision: 10, scale: 2
    t.decimal "anglo_american_price", precision: 10, scale: 2
    t.decimal "arcelor_price", precision: 10, scale: 2
    t.decimal "modec_price", precision: 10, scale: 2
    t.decimal "petrobras_price", precision: 10, scale: 2
    t.string "code"
    t.string "unit"
    t.boolean "is_active", default: true
    t.decimal "ipi", precision: 5, scale: 2, default: "0.0"
    t.string "income"
    t.text "characteristics"
    t.decimal "ncm", precision: 15, scale: 1
  end

  create_table "products_requests", id: false, force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "request_id", null: false
    t.index ["product_id", "request_id"], name: "index_products_requests_on_product_id_and_request_id"
    t.index ["request_id", "product_id"], name: "index_products_requests_on_request_id_and_product_id"
  end

  create_table "reports", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2
    t.string "planning"
    t.date "period"
    t.bigint "enterprise_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "product_id"
    t.bigint "user_id"
    t.bigint "request_id"
    t.string "report_type"
    t.bigint "request_installment_id"
    t.index ["enterprise_id"], name: "index_reports_on_enterprise_id"
    t.index ["product_id"], name: "index_reports_on_product_id"
    t.index ["request_id"], name: "index_reports_on_request_id"
    t.index ["request_installment_id"], name: "index_reports_on_request_installment_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "request_conditions", force: :cascade do |t|
    t.string "payment_type"
    t.string "operation_type"
    t.string "storage_center"
    t.string "payment_code"
    t.bigint "request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["request_id"], name: "index_request_conditions_on_request_id"
  end

  create_table "request_installments", force: :cascade do |t|
    t.decimal "value", precision: 15, scale: 2
    t.date "date"
    t.boolean "is_billed", default: false
    t.boolean "is_paid", default: false
    t.bigint "request_id", null: false
    t.index ["request_id"], name: "index_request_installments_on_request_id"
  end

  create_table "request_products", force: :cascade do |t|
    t.decimal "product_quantity", precision: 15, scale: 2
    t.bigint "request_id"
    t.bigint "product_id"
    t.decimal "shipping_price", precision: 12, scale: 2, default: "0.0"
    t.decimal "calculated_price", precision: 15, scale: 2, default: "0.0"
    t.decimal "price_with_discount", precision: 12, scale: 2, default: "0.0"
    t.index ["product_id"], name: "index_request_products_on_product_id"
    t.index ["request_id"], name: "index_request_products_on_request_id"
  end

  create_table "request_proposals", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "request_id"
    t.string "status", default: "not_evaluated"
    t.text "feedback_description"
    t.text "feedback_reasons"
    t.index ["request_id"], name: "index_request_proposals_on_request_id"
  end

  create_table "request_quiz_data", force: :cascade do |t|
    t.text "data"
    t.bigint "request_id"
    t.index ["request_id"], name: "index_request_quiz_data_on_request_id"
  end

  create_table "request_quizzes", force: :cascade do |t|
    t.string "title"
    t.text "data"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position", limit: 2
    t.index ["user_id"], name: "index_request_quizzes_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.integer "step"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "enterprise_id"
    t.bigint "user_id"
    t.bigint "technician_id"
    t.string "request_type"
    t.boolean "is_stock_replacement"
    t.text "equipment_sizes"
    t.bigint "collaborator_id"
    t.bigint "equipment_id"
    t.text "cause_or_reason"
    t.text "solutions"
    t.text "substratum"
    t.text "surface_preparation"
    t.text "fluids"
    t.date "response_time"
    t.string "shipping_type"
    t.decimal "value_estimation", precision: 12, scale: 2, default: "0.0"
    t.decimal "calculated_revenue", precision: 15, scale: 2, default: "0.0"
    t.boolean "is_draft", default: false
    t.boolean "is_valid", default: false
    t.string "title"
    t.decimal "real_loose_value", precision: 15, scale: 2, default: "0.0"
    t.decimal "planned_loose_value", precision: 15, scale: 2, default: "0.0"
    t.decimal "planned_products_value", precision: 15, scale: 2, default: "0.0"
    t.decimal "planned_service_value", precision: 15, scale: 2, default: "0.0"
    t.decimal "planned_request_value", precision: 15, scale: 2, default: "0.0"
    t.boolean "is_active", default: true
    t.string "shipping_modality"
    t.boolean "is_billed", default: false
    t.boolean "high_urgency", default: false
    t.text "tag", default: ""
    t.decimal "pressure_proj", precision: 7, scale: 2
    t.decimal "pressure_opr", precision: 7, scale: 2
    t.decimal "temperature_proj", precision: 15, scale: 2
    t.decimal "temperature_opr", precision: 15, scale: 2
    t.bigint "request_code"
    t.bigint "draft_owner_id"
    t.bigint "created_by_id"
    t.text "observation"
    t.string "proposal_code"
    t.index ["collaborator_id"], name: "index_requests_on_collaborator_id"
    t.index ["enterprise_id"], name: "index_requests_on_enterprise_id"
    t.index ["equipment_id"], name: "index_requests_on_equipment_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "requirements", force: :cascade do |t|
    t.string "title"
    t.string "requirement_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "weight", precision: 8, scale: 2
    t.decimal "max", precision: 8, scale: 2
  end

  create_table "stocks", force: :cascade do |t|
    t.string "filename"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_score_criterions", force: :cascade do |t|
    t.integer "criterion_type"
    t.boolean "status"
    t.integer "year"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_score_criterions_on_user_id"
  end

  create_table "user_scores", force: :cascade do |t|
    t.date "period"
    t.string "level"
    t.string "comment"
    t.integer "quantity"
    t.decimal "value", precision: 8, scale: 2
    t.decimal "score", precision: 8, scale: 2
    t.bigint "requirement_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "score_type"
    t.bigint "responsible_id"
    t.bigint "request_id"
    t.bigint "request_proposal_id"
    t.index ["request_id"], name: "index_user_scores_on_request_id"
    t.index ["request_proposal_id"], name: "index_user_scores_on_request_proposal_id"
    t.index ["requirement_id"], name: "index_user_scores_on_requirement_id"
    t.index ["user_id"], name: "index_user_scores_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "phone"
    t.integer "role"
    t.date "admission"
    t.string "team"
    t.string "authentication_token", limit: 30
    t.boolean "is_active", default: true
    t.string "cnpj"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "commissions", "requests"
  add_foreign_key "enterprises", "users"
  add_foreign_key "request_conditions", "requests"
  add_foreign_key "user_score_criterions", "users"
end
