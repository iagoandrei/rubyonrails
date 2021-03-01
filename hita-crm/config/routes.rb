Rails.application.routes.draw do
  resources :commissions
  devise_for :users, controllers: { sessions: 'users/sessions' }, path_names: { sign_up: '' }

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'app#index'

   # resources :request_conditions

  resources :request_conditions do
    put :update, on: :member
  end

    match '/condicoes/criar' => "request_conditions#create", via: :post, as: :conditions_create 
    match '/commisao/criar' => "commissions#create", via: :post, as: :commissions_create 
    match '/condicoes/get' => "request_conditions#index", via: :get, as: :conditions_get
    match '/condicoes/get_commis_by_id' => "request_conditions#get_commis_by_id", via: :get, as: :get_commis_by_id



  namespace :api do
    match '/user_access_token' => "tokens#user_access_token", via: :post, as: :user_access_token

    match '/enterprise/create' => "enterprises#create", via: :post, as: :create_enterprise
    match '/user_enterprises' => "enterprises#user_enterprises", via: :get, as: :user_enterprises

    match '/collaborators/create' => "collaborators#create", via: :post, as: :create_collaborator
    match '/enterprise_collaborators' => "collaborators#enterprise_collaborators", via: :get, as: :enterprise_collaborators

    match '/get_equipment_infos' => "equipments#get_equipment_infos", via: :get, as: :get_equipment_infos

    match '/get_available_products' => "products#get_available_products", via: :get, as: :get_available_products

    match '/request/create' => 'requests#create', via: :post, as: :create_request
    match '/request/show_all' => 'requests#show_all', via: :get, as: :show_all_requests
    put   '/request/update/:id' => 'requests#update', via: :put, as: :update_request
  end
 
  #MAP
  match '/empresas/mapa' => "enterprises#map", via: :get, as: :enterprises_map

  match '/getrequestCode' => "requests#getrequestCode", via: :post, as: :getrequestcode

  match '/getallusers' => "users#getallusers", via: :get, as: :getallusers
    
  match '/empresas/contatos' => "collaborators#index", via: :get, as: :collaborators_index
  match '/empresas/contatos/novo' => "collaborators#create", via: :post, as: :create_new_collaborator
  match '/update_collaborator' => "collaborators#update", via: :post, as: :update_collaborator
  match '/destroy_collaborator' => "collaborators#destroy", via: :delete, as: :destroy_collaborator
  match '/render_current_collaborators' => "collaborators#render_current_collaborators", via: :get, as: :render_current_collaborators
  match '/get_collaborator_infos/:id' => "collaborators#get_collaborator_infos", via: :get, as: :get_collaborator_infos
  match '/get_collaborator_interactions/:id' => "collaborators#get_interactions", via: :get, as: :get_collaborator_interactions
  match '/create_collaborator_interaction' => "collaborators#create_interaction", via: :post, as: :create_collaborator_interaction
  match '/check_collaborator_existence' => "collaborators#check_existence", via: :post, as: :check_collaborator_existence
  match '/get_collaborator_by_enterprise' => "collaborators#get_collaborators_by_enterprise", via: :get, as: :get_collaborator_by_enterprise

  match '/empresas' => "enterprises#index", via: :get, as: :enterprises_index
  match '/empresas/nova' => "enterprises#create", via: :post, as: :create_new_enterprise
  match '/update_enterprise' => "enterprises#update", via: :post, as: :update_enterprise
  match '/render_current_enterprises' => "enterprises#render_current_enterprises", via: :get, as: :render_current_enterprises
  match '/enterprise_autocomplete' => "enterprises#enterprises_autocomplete", via: :get, as: :enterprises_autocomplete
  match '/get_enterprise_infos/:id' => "enterprises#get_enterprise_infos", via: :get, as: :get_enterprise_infos
  match '/get_enterprise_interactions/:id' => "enterprises#get_interactions", via: :get, as: :get_enterprise_interactions
  match '/create_enterprise_interaction' => "enterprises#create_interaction", via: :post, as: :create_enterprise_interaction
  match '/upload_enterprise_chart' => "enterprises#upload_chart", via: :post, as: :upload_enterprise_chart
  match '/upload_enterprise_file' => "enterprises#upload_file", via: :post, as: :upload_enterprise_file
  match '/get_enterprise_files/:id' => "enterprises#render_enterprise_files", via: :get, as: :get_enterprise_files
  match '/remove_enterprise_file' => "enterprises#remove_file", via: :post, as: :remove_enterprise_file
  match '/destroy_enterprise/:id' => "enterprises#destroy", via: :delete, as: :destroy_enterprise
  match '/check_enterprise_existence' => "enterprises#check_existence", via: :post, as: :check_enterprise_existence
  match '/get_enterprise_charts' => "enterprises#get_enterprise_charts", via: :get, as: :get_enterprise_charts
  match '/get_enterprise_requests/:id' => "enterprises#get_enterprise_requests", via: :get, as: :get_enterprise_requests
  match '/render_map_enterprises' => "enterprises#mapfilter", via: :get, as: :get_map_filter

  match '/get_city_list/:state' => "app#get_city_list", via: :get, as: :get_city_list

  match '/propostas' => "proposals#index", via: :get, as: :proposals_index
  match '/propostas/nova' => "proposals#create", via: :post, as: :create_proposal
  match '/get_proposal_files/:id' => "proposals#get_proposal_files", via: :get, as: :get_proposal_files

  match '/estoque' => 'stocks#index', via: :get, as: :stocks_index
  match '/estoque/novo' => 'stocks#new', via: :get, as: :stocks_new
  match '/upload_document_stock' => 'stocks#upload', via: :post, as: :upload_document_stock
  match '/request_product_table/(:product_type)' => 'stocks#request_product_table', via: :get, as: :request_product_table
  match '/check_product_by_code/:code' => 'stocks#check_product_by_code', via: :get, as: :check_product_by_code

  match '/oportunidades' => "requests#index", via: :get, as: :requests_index
  match '/oportunidades/novo' => "requests#new", via: :get, as: :new_request
  match '/oportunidades/create' => "requests#create", via: :post, as: :create_new_request
  match '/oportunidades/create_draft' => "requests#create_draft", via: :post, as: :create_new_draft
  match '/oportunidades/servicos' => "requests#show_services_index", via: :get, as: :services_index
  match '/oportunidades/elaborar_proposta' => "requests#elaborate_proposals", via: :get, as: :elaborate_proposals_index
  #Aqui!
  match '/oportunidades/get_products_from_req' => "requests#get_products_from_req", via: :get, as: :get_p_f_r

  match '/oportunidades/elaborar_proposta/:id' => "requests#edit", via: :get, as: :edit_request
  match '/oportunidades/update' => "requests#update", via: :post, as: :update_request
  match '/oportunidades/rascunhos' => "requests#see_drafts", via: :get, as: :see_drafts
  match '/oportunidades/remover_rascunho/:id' => "requests#destroy_draft", via: :delete, as: :destroy_request_draft
  match '/oportunidades/rascunho/:id' => "requests#edit_draft", via: :get, as: :edit_request_draft

  match '/render_current_requests' => "requests#render_request_table", via: :get, as: :render_request_table
  match '/add_technician_to_request' => "requests#add_technician", via: :post, as: :add_technician
  match '/get_request_infos/(:id)' => "requests#get_request_infos", via: :get, as: :get_request_infos
  match '/get_request_infos_product/(:id)' => "requests#get_request_infos_products", via: :get, as: :get_request_infos_product

  match '/update_request_step' => "requests#update_request_step", via: :get, as: :update_request_step
  match '/update_funnels_infos' => "requests#update_funnels_infos", via: :get, as: :update_funnels_infos
  match '/create_request_interaction' => "requests#create_comment_interaction", via: :post, as: :create_request_interaction
  match '/get_request_interactions/:id' => "requests#get_interactions", via: :get, as: :get_request_interactions
  match '/upload_request_file' => "requests#upload_file", via: :post, as: :upload_request_file
  match '/get_request_files' => "requests#get_request_files", via: :get, as: :get_request_files
  match '/remove_request_file' => "requests#remove_file", via: :post, as: :remove_request_file
  match '/get_enteprise_requests' => "requests#get_enteprise_requests", via: :get, as: :get_enteprise_requests

  match '/request_by_enter_id' => "requests#get_enterprise_id", via: :get, as: :get_enterprise_id


  match '/update_request_enterprise' => "requests#update_request_enterprise", via: :post, as: :update_request_enterprise

  match '/remove_request_proposal' => "request_proposals#remove_request_proposal", via: :post, as: :remove_request_proposal
  match '/get_request_proposals' => "request_proposals#get_request_proposals", via: :get, as: :get_request_proposals
  match '/request_proposal_feedback' => "request_proposals#request_proposal_feedback", via: :post, as: :request_proposal_feedback
  match '/create_fake_request_proposal' => "request_proposals#create_fake_request_proposal", via: :post, as: :create_fake_request_proposal
 
  match '/upload_request_specific_file' => "requests#upload_specific_file", via: :post, as: :upload_request_specific_files
  match '/biblioteca' => "requests#index_database", via: :get, as: :index_database
  match '/get_filter_values' => "requests#get_filter_values", via: :post, as: :get_filter_values
  match '/filter_requests_database' => "requests#filter_requests_database", via: :post, as: :filter_requests_database
  match '/technician_request_validation' => "requests#technician_request_validation", via: :post, as: :technician_request_validation
  match '/get_request_values' => "requests#get_request_values", via: :get, as: :get_request_values
  match '/update_request_values' => "requests#update_request_values", via: :post, as: :update_request_values
  match '/archive_request' => "requests#archive_request", via: :post, as: :archive_request

  match '/installments/get_request_installments_infos' => "request_installments#get_request_installments_infos", via: :get, as: :get_request_installments_infos
  match '/installments/save_installments' => "request_installments#save_installments", via: :post, as: :save_installments

  match '/impedimentos' => "hindrances#index", via: :get, as: :hindrance_index
  match '/impedimentos/outros' => "hindrances#show_others_hindrances", via: :get, as: :others_hindrances
  match '/create_hindrance' => "hindrances#create", via: :post, as: :create_hindrance
  match '/change_hindrance' => "hindrances#change_hindrance", via: :post, as: :change_hindrance
  match '/render_hindrance_table' => "hindrances#render_hindrance_table", via: :get, as: :render_hindrance_table
  match '/remove_request_hindrance' => "hindrances#destroy_request_hindrance", via: :post, as: :remove_request_hindrance
  match '/change_due_time' => "hindrances#change_due_time", via: :post, as: :change_due_time


  match '/create_user' => "users#create", via: :post, as: :create_user
  match '/usuarios' => "users#index", via: :get, as: :index_user
  match '/editar_usuario/:id' => "users#edit", via: :get, as: :edit_user
  match '/update_user' => "users#update", via: :post, as: :update_user
  match '/get_user_infos/:id' => "users#get_user_infos", via: :get, as: :get_user_infos
  match '/user_autocomplete(/:role)' => "users#users_autocomplete", via: :get, as: :users_autocomplete
  match '/update_user_password' => "users#update_password", via: :post, as: :update_user_password

  match '/minha_agenda' => 'events#index', via: :get, as: :events_index
  match '/create_new_event' => 'events#create', via: :post, as: :create_new_event
  match '/destroy_event/:id' => 'events#destroy', via: :delete, as: :destroy_event
  match '/get_event_infos/:id' => 'events#get_event_infos', via: :get, as: :get_event_infos
  match '/update_event' => 'events#update', via: :post, as: :update_event
  match '/render_events' => 'events#render_events', via: :get, as: :render_events
  match '/render_events_calendar' => 'events#render_events_calendar', via: :get, as: :render_events_calendar
  match '/finalize_event' => 'events#finalize', via: :post, as: :finalize_event
  match '/agendas' => 'events#show_all', via: :get, as: :show_all_events

  match '/formularios' => "forms#index", via: :get, as: :forms_index
  match '/formularios/novo' => "forms#new_form", via: :get, as: :new_form
  match '/create_new_form' => "forms#create", via: :post, as: :create_new_form
  match '/generate_form' => "forms#generate_form", via: :get, as: :generate_form
  match '/update_form_template' => "forms#update_template", via: :post, as: :update_form_template
  match '/destroy_form_template/:id' => "forms#destroy", via: :delete, as: :destroy_form_template

  match '/gerar_proposta' => "forms#index_proposal", via: :get, as: :forms_proposal_index
  match '/criar_proposta' => "forms#new_proposal_form", via: :get, as: :new_proposal_form
  match '/create_proposal_form' => "forms#create_proposal", via: :post, as: :create_proposal_form

  match '/redirect_notification/:id' => 'notifications#redirect', via: :get, as: :redirect_notification
  match '/render_current_notifications' => 'notifications#render_current_notifications', via: :get, as: :render_current_notifications

  match '/formularios/chaves' => "form_keys#index", via: :get, as: :form_keys_index
  match '/formularios/chaves/nova_chave' => "form_keys#create", via: :post, as: :create_form_keys
  match '/formularios/chaves/remover/:id' => "form_keys#destroy", via: :delete, as: :destroy_form_key
  match '/formularios/chaves/:id' => "form_keys#edit", via: :get, as: :edit_form_keys
  match '/update_form_key' => "form_keys#update", via: :post, as: :update_form_keys

  match '/perguntas' => "request_quiz#index", via: :get, as: :request_quiz_index
  match '/perguntas/novo' => "request_quiz#new", via: :get, as: :new_request_quiz
  match '/perguntas/criar' => "request_quiz#create", via: :post, as: :create_request_quiz
  match '/perguntas/editar/:id' => "request_quiz#edit", via: :get, as: :edit_request_quiz
  match '/perguntas/atualizar' => "request_quiz#update", via: :post, as: :update_request_quiz
  match '/perguntas/remover/:id' => "request_quiz#destroy", via: :delete, as: :destroy_request_quiz
  match '/get_request_quiz_data' => "request_quiz#get_quiz_data", via: :get, as: :get_quiz_data
  match '/update_quiz_position' => "request_quiz#update_position", via: :post, as: :update_quiz_position
  match '/get_request_quiz_identifiers' => "request_quiz#get_request_quiz_identifiers", via: :get, as: :get_request_quiz_identifiers

  match '/questionarios' => "equipments#manage_quizzes", via: :get, as: :manage_quizzes_index
  match '/questionarios/atualizar' => "equipments#update_question", via: :post, as: :update_equipment_questions

  match '/equipamentos' => "equipments#index", via: :get, as: :equipments_index
  match '/equipamentos/novo' => "equipments#new", via: :get, as: :equipments_new
  match '/equipamentos/criar' => "equipments#create", via: :post, as: :create_equipment
  match '/equipamentos/editar/:id' => "equipments#edit", via: :get, as: :edit_equipment
  match '/equipamentos/atualizar' => "equipments#update", via: :post, as: :update_equipment
  match '/equipamentos/apagar/:id' => "equipments#destroy", via: :delete, as: :destroy_equipment
  match '/equipamentos/remover_image/:blob_id' => "equipments#remove_image", via: :delete, as: :remove_equipment_image
  match '/equipments/get_infos' => "equipments#get_equipment_infos", via: :get, as: :get_equipment_infos
 
  match '/produtos' => "products#index", via: :get, as: :products_index
  match '/produtos/atualizar_tabela' => "products#update_product", via: :post, as: :update_product
  match '/produtos/atualizar_dolar' => "products#update_dollar_value", via: :post, as: :update_dollar_value
  match '/product/check_product_price' => "products#check_product_price", via: :get, as: :check_product_price

  match '/produtos/criar' => "products#create", via: :post, as: :create_products
  match '/produtos/todos' => "products#allproducts", via: :get, as: :all_products
  match '/produtos/atualizar' => "products#update", via: :post, as: :update_product_cigam

  match '/relatorios/empresas' => 'reports#index', via: :get, as: :report_index
  match '/render_current_enterprises_reports' => "reports#render_current_enterprises_reports", via: :get, as: :render_current_enterprises_reports
  match '/filter_enterprises' => "reports#filter_enterprises", via: :post, as: :filter_enterprises
  match '/create_new_report' => "reports#create", via: :post, as: :create_new_report

  match '/relatorios/produtos' => 'reports#index_products', via: :get, as: :report_products_index
  match '/render_current_products_reports' => "reports#render_current_products_reports", via: :get, as: :render_current_products_reports

  match '/relatorios/servicos' => 'reports#index_services', via: :get, as: :report_services_index

  match '/meus_pontos' => "requirements#index", via: :get, as: :requirements_index
  match '/pontos' => "requirements#index_technical_manager", via: :get, as: :index_technical_manager
  match '/requirements_render_months' => "requirements#render_months", via: :get, as: :requirements_render_months
  match '/get_requirement_infos/:id' => "requirements#get_requirement_infos", via: :get, as: :get_requirement_infos
  match '/render_individual_user_scores_month' => "requirements#render_individual_user_scores_month", via: :get, as: :render_individual_user_scores_month

  match '/create_user_score' => "user_scores#create", via: :post, as: :user_scores_create
  match '/destroy_user_score/:id' => "user_scores#destroy", via: :delete, as: :user_scores_destroy
  match '/render_user_scores_month' => "user_scores#render_user_scores_month", via: :get, as: :render_user_scores_month

  match '/change_state_user_score_criterion' => 'user_score_criterions#change_state', via: :post, as: :change_state_user_score_criterion
end
