class RequestsController < ApplicationController
  include HindrancesHelper

  def index
    @title = "Hita CRM | Oportunidades"
  end
    
  def new
    @title = "Hita CRM | Solicitar Proposta"
    @avaliable_quizzes = Equipment.all.order(name: 'ASC').pluck(:name, :id)
    @product_list = Product.where.not(name: ['Frete', 'Valor Serviço']).where(is_active: true).order(name: 'ASC').pluck(:name, :code)

    if params[:enterprise_id].present?
      @enterprise         = Enterprise.find_by_id params[:enterprise_id]
      @show_collaborators = true
    end
  end

  def elaborate_proposals
    @title = "Hita CRM | Elaborar Proposta"
    @requests = Request.where(technician_id: current_user.id, is_draft: false, is_active: true)
  end

  def see_drafts
    @title = "Hita CRM | Rascunhos"
    @requests = Request.where(is_draft: true, draft_owner: current_user.id, is_active: true).order(created_at: 'DESC')
  end

  def edit_draft
    @title = "Hita CRM | Editar Rascunho"
    @request = Request.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    @collaborators = @request.enterprise.collaborator.pluck(:name, :id)

    @equipment = Equipment.find_by id: @request.equipment&.id
    @avaliable_quizzes = Equipment.all.order(name: 'ASC').pluck(:name, :id)

    @attachments = []
    @request.files.each do |file|
      @attachments << [file.filename.to_s, rails_blob_path(file, disposition: 'attachment')]
    end

    price_table = @request.enterprise.price_table

    @products_prices = {}
    @request.request_products.each do |product|
      @products_prices[product.product.code] = product.product.get_product_price(price_table).to_f
    end

    @request_products = []
    @request.request_products.each do |product|
      current_product = {}
      current_product['name'] = product.product.name
      current_product['code'] = product.product.code
      current_product['quantity'] = product.product_quantity
      current_product['shipping'] = product.shipping_price.to_f

      @request_products << current_product
    end

    @product_list = Product.where.not(name: ['Frete', 'Valor Serviço']).where(is_active: true).order(name: 'ASC').pluck(:name, :code)
  end

  def edit
    @title = "Hita CRM | Elaborar Proposta"

    @request = Request.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    @avaliable_quizzes =
    if @request.request_type == 'service'
      [[@request.equipment.name, @request.equipment.id]]
    else
      Equipment.all.order(name: 'ASC').pluck(:name, :id)
    end

    @attachments = []
    @request.files.each do |file|
      @attachments << [file.filename.to_s, rails_blob_path(file, disposition: 'attachment')]
    end

    price_table = @request.enterprise.price_table

    @products_prices = {}
    @request.request_products.each do |product|
      @products_prices[product.product.code] = product.product.get_product_price(price_table).to_f
    end

    @request_products = []
    @request.request_products.each do |product|
      current_product = {}
      current_product['name'] = product.product.name
      current_product['code'] = product.product.code
      current_product['quantity'] = product.product_quantity
      current_product['shipping'] = product.shipping_price.to_f

      @request_products << current_product
    end

    @product_list = Product.where.not(name: ['Frete', 'Valor Serviço']).where(is_active: true).order(name: 'ASC').pluck(:name, :code)
  end

  def update
    request = Request.find_by id: params[:request_data][:request_id]
    request.request_type = params[:request_data][:request_type]

    if request.request_type == 'service'
      request.is_stock_replacement = false
      request.value_estimation = convert_br_currency_to_float(params[:request_data][:service_value_estimation])
    else
      request.is_stock_replacement = params[:request_data][:stock_replacement] == 'true'
      request.value_estimation = 0
    end

    collaborator = Collaborator.find_by id: params[:request_data][:collaborator_id]
    request.collaborator = collaborator

    if request.is_stock_replacement
      request.equipment = nil
      request.equipment_sizes = nil
    else
      equipment = Equipment.find_by id: params[:request_data][:equipment_id]

      if equipment
        request.equipment = equipment
        request.equipment_sizes = params[:equipment_measures]
      end
    end

    if request.is_draft and params[:request_data][:is_draft].present? and params[:request_data][:is_draft] == "false"
      technical_managers = User.where(role: User::ROLES[:technical_manager], is_active: true)
      technical_managers.each do |manager|
        hindrance_params = {
          detainee_id: manager.id,
          request_id: request.id
        }

        HindrancesHelper.create_hindrance(hindrance_params)
      end

      if !request.interactions.exists?(interaction_type: 'requested_by')
        interaction_params = {
          owner_id: current_user.id,
          content: "<b>#{current_user.name}</b> solicitou uma nova proposta.",
          request_id: request.id,
          current: 'request'
        }

        InteractionHelper.create 'requested_by', interaction_params
      end
    end

    request.response_time = params[:request_data][:response_time]
    request.shipping_type = params[:request_data][:shipping_type]
    request.shipping_modality = params[:request_data][:shipping_modality]
    request.is_draft = params[:request_data][:is_draft] if params[:request_data][:is_draft].present?
    request.observation = params[:request_data][:observations]

    if request.is_draft
      request.draft_owner = current_user
    else
      request.created_by = current_user
    end

    if request.save
      if request.is_stock_replacement
        title = "#{request.enterprise.name[0, 3]}_repo_#{request.id.to_s.rjust(6, '0')}".upcase
        request.request_quiz_data.destroy_all
      else
        if equipment.nil?
          title = "#{request.enterprise.name[0, 3]}_RASC_#{request.id.to_s.rjust(6, '0')}".upcase
        else
          title = "#{request.enterprise.name[0, 3]}_#{request.equipment.name[0, 4]}_#{request.id.to_s.rjust(6, '0')}".upcase
        end
      end

      request.update_attribute(:title, title)

      if params[:quiz_data].present?

        request.request_quiz_data.destroy_all

        params[:quiz_data].each do |quiz_data|
          RequestQuizData.create(data: quiz_data, request_id: request.id)

          parsed_data = JSON.parse(quiz_data)
          parse_chatbot_answers(request, parsed_data)
        end
      end

      request.request_products.destroy_all

      if params[:products].present?
        store_request_products_with_shipping(request, params[:products], convert_br_currency_to_float(params[:request_data][:total_shipping]))
      end

      request.proposal_code = generate_proposal_code(request, params[:products])
      request.save
    else
      return render json: { error: true, message: 'Houve um erro ao salvar a oportunidade.' }, status: :internal_server_error
    end

    return render json: { id: request.id, message: 'Oportunidade foi atualizada com sucesso.' }
  end

  def create
    enterprise = Enterprise.find_by id: params[:request_data][:enterprise_id]
    return render json: { error: true, message: 'Empresa não encontrada.' }, status: 404 if enterprise.nil?

    collaborator = Collaborator.find_by id: params[:request_data][:collaborator_id]
    return render json: { error: true, message: 'Contato não encontrado.' }, status: 404 if collaborator.nil?

    equipment = Equipment.find_by id: params[:request_data][:equipment_id]

    if equipment.nil? and params[:request_data][:stock_replacement] == 'false'
      return render json: { error: true, message: 'Equipamento não encontrado.' }, status: 404
    end

    request = Request.new
    request.equipment = equipment
    request.enterprise = enterprise
    request.collaborator = collaborator
    request.user = enterprise.user

    request.is_stock_replacement = params[:request_data][:stock_replacement] == 'true'
    request.is_draft = params[:request_data][:is_draft] if params[:request_data][:is_draft].present?

    if request.is_draft
      request.draft_owner = current_user
    else
      request.created_by = current_user

      interaction_params = {
        owner_id: current_user.id,
        content: "<b>#{current_user.name}</b> solicitou uma nova proposta.",
        request_id: request.id,
        current: 'request'
      }

      InteractionHelper.create 'requested_by', interaction_params
    end

    request.request_type = params[:request_data][:request_type]
    request.equipment_sizes = params[:equipment_measures]
    request.response_time = params[:request_data][:response_time]
    request.observation = params[:request_data][:observations]

    request_time = Time.parse("#{request.response_time} #{Time.now.strftime('%H:%M')}")
    time_diff = ((request_time - Time.now) / 3600).round

    if time_diff <= 24 and request.is_draft == false
      request.high_urgency = true
    end

    request.shipping_type = params[:request_data][:shipping_type]
    request.value_estimation = convert_br_currency_to_float(params[:request_data][:service_value_estimation])
    request.shipping_modality = params[:request_data][:shipping_modality]

    if request.save
      if request.is_stock_replacement
        title = "#{enterprise.name[0, 3]}_repo_#{request.get_request_code}".upcase
      else
        title = "#{enterprise.name[0, 3]}_#{equipment.name[0, 4]}_#{request.get_request_code}".upcase
      end

      request.update_attribute(:title, title)

      if params[:quiz_data].present?
        params[:quiz_data].each do |quiz_data|
          RequestQuizData.create(data: quiz_data, request_id: request.id)

          parsed_data = JSON.parse(quiz_data)
          parse_chatbot_answers(request, parsed_data)
        end
      end

      if params[:products].present?
        store_request_products_with_shipping(request, params[:products], convert_br_currency_to_float(params[:request_data][:total_shipping]))
      end

      request.proposal_code = generate_proposal_code(request, params[:products])
      request.save
    else
      return render json: { error: true, message: 'Houve um erro ao salvar a oportunidade.' }, status: :internal_server_error
    end

    return render json: { id: request.id, message: 'Oportunidade foi criada com sucesso.' }
  end

  def parse_chatbot_answers request, parsed_data
    if parsed_data['name'].downcase == 'causa/motivo'
      request.cause_or_reason = parsed_data["questions"][0]["user_answers"].pluck("text")
    end

    if parsed_data['name'].downcase == 'preparação de superfície'
      request.surface_preparation = parsed_data['questions'][0]['user_answers'][0]['text']
    end

    if parsed_data['name'].downcase == 'tag'
      request.tag = parsed_data['questions'][0]['user_answers'][0]['text']
    end

    if parsed_data['name'].downcase == 'substrato'
      request.substratum = parsed_data['questions'][0]['user_answers'][0]['text'].strip
    end

    if parsed_data['name'].downcase == 'soluções'
      request.solutions = parsed_data['questions'][0]['user_answers'].pluck("text")
    end

    if parsed_data['name'].downcase == 'fluido e concentração'
      request.fluids = parse_fluid_data(parsed_data)
    end

    if parsed_data['name'].downcase == 'temperatura'
      parsed_value = parsed_data['questions'][0]['user_answers'][0]['text']
      parsed_value.remove!(' ºC').gsub!(',','.').to_f
      request.temperature_proj = parsed_value

      parsed_value = parsed_data['questions'][1]['user_answers'][0]['text']
      parsed_value.remove!(' ºC').gsub!(',','.').to_f
      request.temperature_opr = parsed_value
    end

    if parsed_data['name'].downcase == 'pressão'
      parsed_value = parsed_data['questions'][0]['user_answers'][0]['text']
      parsed_value.gsub!(',','.').to_f
      request.pressure_proj = parsed_value

      parsed_value = parsed_data['questions'][1]['user_answers'][0]['text']
      parsed_value.gsub!(',','.').to_f
      request.pressure_opr = parsed_value
    end

    request.save
  end


  def create_draft
    enterprise = Enterprise.find_by id: params[:request_data][:enterprise_id]
    return render json: { error: true, message: 'Empresa não encontrada.' }, status: 404 if enterprise.nil?

    collaborator = Collaborator.find_by id: params[:request_data][:collaborator_id]
    equipment = Equipment.find_by id: params[:request_data][:equipment_id]

    request = Request.new
    request.equipment = equipment
    request.enterprise = enterprise
    request.collaborator = collaborator
    request.user = enterprise.user

    request.is_stock_replacement = params[:request_data][:stock_replacement] == 'true'
    request.is_draft = true

    if request.is_draft
      request.draft_owner = current_user
    else
      request.created_by = current_user
    end

    request.request_type = params[:request_data][:request_type]
    request.equipment_sizes = params[:equipment_measures]
    request.response_time = params[:request_data][:response_time]
    request.observation = params[:request_data][:observations]

    request_time = Time.parse("#{request.response_time} #{Time.now.strftime('%H:%M')}")
    time_diff = ((request_time - Time.now) / 3600).round

    if time_diff <= 24 and request.is_draft == false
      request.high_urgency = true
    end

    request.shipping_type = params[:request_data][:shipping_type]
    request.value_estimation = convert_br_currency_to_float(params[:request_data][:service_value_estimation])
    request.shipping_modality = params[:request_data][:shipping_modality]

    if request.save
      if request.is_stock_replacement
        title = "#{enterprise.name[0, 3]}_repo_#{request.get_request_code}".upcase
      else
        title = "#{enterprise.name[0, 3]}_RASC_#{request.get_request_code}".upcase
      end

      request.update_attribute(:title, title)

      if params[:quiz_data].present?
        params[:quiz_data].each do |quiz_data|
          RequestQuizData.create(data: quiz_data, request_id: request.id)
        end

        request.save
      end

      if params[:products].present?
        store_request_products_with_shipping(request, params[:products], convert_br_currency_to_float(params[:request_data][:total_shipping]))
      end

      request.save
    else
      return render json: { error: true, message: 'Houve um erro ao salvar a oportunidade.' }, status: :internal_server_error
    end

    return render json: { id: request.id, message: 'Oportunidade foi criada com sucesso.' }
  end

  def parse_fluid_data data
    parsed_data = data['questions']
    parsed_array = []

    i = 2
    last_fluid = false
    while (parsed_data[i] and !last_fluid)

      current_answer = ''
      current_answer = parsed_data[i-2]['user_answers'][0]['text'] unless parsed_data[i-2]['user_answers'].empty?

      if not current_answer.in? ProposalsHelper::FLUIDS
        i += 3
        next
      end

      unless parsed_data[i-1]['user_answers'].empty?
        concentration_value = parsed_data[i-1]['user_answers'][0]['text']
        concentration_value.remove!(" %")

        current_answer += '/' + concentration_value.to_f.truncate.to_s
      end

      parsed_array << current_answer

      if !parsed_data[i]['user_answers'][0] or parsed_data[i]['user_answers'][0]['text'].downcase != 'sim'
        last_fluid = true
      end

      i += 3
    end

    return parsed_array
  end

  def parse_temperature_data data
    parsed_answer = ''

    if data['questions'][0]['user_answers'][0]['text'].downcase == 'projeto'
      parsed_answer = 'Projeto'
      parsed_answer += "/#{data['questions'][1]['user_answers'][0]['text'].capitalize}"
      parsed_answer += "/#{data['questions'][2]['user_answers'][0]['text'].capitalize}"
    else
      parsed_answer = 'Operação'
      parsed_answer += "/#{data['questions'][3]['user_answers'][0]['text'].capitalize}"
      parsed_answer += "/#{data['questions'][4]['user_answers'][0]['text'].capitalize}"
    end

    return parsed_answer
  end

  def show_services_index
    @title = "Hita CRM | Oportunidades"
  end

  def render_request_table
    @requests = search_requests params

    if params[:request_type] == 'product'
      params[:step] = [1, 2, 3, 4, 5, 6]
    else
      params[:step] = [1, 2, 3, 4, 5, 6, 7, 8]
    end

    tab_quantities = search_requests params
    tab_quantities = tab_quantities.group_by(&:step)

    @step_quantities = []
    params[:step].each do |step|
      count = tab_quantities[step]&.size
      @step_quantities << (count ? count : 0)
    end

    @request_type = params[:request_type]
    @funnel_steps = build_funnel_infos(params)
  end

  def search_requests params
    search_obj = {}
    search_obj[:is_draft] = false
    search_obj[:step] = params[:step] if params[:step].present?
    search_obj[:enterprise_id] = params[:enterprise_id] if params[:enterprise_id].present?
    search_obj[:user_id] = params[:user_id] if params[:user_id].present?
    search_obj[:request_type] = params[:request_type] if params[:request_type].present?
    search_obj[:enterprise_id] = params[:enterprise_id] if params[:enterprise_id].present?
    search_obj[:is_active] = true

    start_date = DateTime.parse(params[:start_date]).beginning_of_day if params[:start_date].present?
    end_date = DateTime.parse(params[:end_date]).end_of_day if params[:end_date].present?

    if current_user.role?(User::ROLES[:regional_coordinator])
      if params[:user_id].present?
        user_ids = params[:user_id]
      else
        user_ids = User.where(team: current_user.team, is_active: true).pluck(:id)
        user_ids << current_user.id
      end

      search_obj[:user_id] = user_ids
    elsif current_user.role?(User::ROLES[:consultant])
      search_obj[:user_id] = current_user.id
    end

    results = Request.where(search_obj)

    if start_date.present? && end_date.present?
      results = results.where(created_at: start_date..end_date)
    end

    return results.order(created_at: :desc)
  end

  def build_funnel_infos params
    start_date = DateTime.parse(params[:start_date]).beginning_of_day if params[:start_date].present?
    end_date = DateTime.parse(params[:end_date]).end_of_day if params[:end_date].present?
    steps_interactions = ['in_line', 'elaboration', 'approval', 'revenue', 'mobilization', 'payment', 'execution', 'finished']

    if params[:request_type] == 'product'
      params[:step] = [1, 2, 3, 4, 5, 6]
    else
      params[:step] = [1, 2, 3, 4, 5, 6, 7, 8]
    end

    requests = search_requests params
    requests = requests.group_by(&:step)

    steps = params[:step]

    steps_hash =
    if params[:request_type] == 'product'
      {
        1 => 'in_line',
        2 => 'elaboration',
        3 => 'approval',
        4 => 'revenue',
        5 => 'mobilization',
        6 => 'payment'
      }
    else
      {
        1 => 'in_line',
        2 => 'elaboration',
        3 => 'approval',
        4 => 'mobilization',
        5 => 'execution',
        6 => 'revenue',
        7 => 'payment',
        8 => 'aftersale'
      }
    end

    highest = requests.map { |step, requests| requests.size }.max
    funnel_steps = {}
    steps.each do |step|
      funnel_steps[steps_hash[step].to_sym] = {}
      funnel_steps[steps_hash[step].to_sym][:size] =
      if requests[step]
        requests[step].size
      else
        0
      end

      funnel_steps[steps_hash[step].to_sym][:amount] =
      if requests[step]
        requests[step].reduce(0) { |sum, request| sum + request.calculate_request_revenue }.to_f
      else
        0
      end

      funnel_steps[steps_hash[step].to_sym][:bar_width] =
      if requests[step]
        (requests[step].size/highest.to_f)*100
      else
        12
      end
    end

    funnel_steps
  end

  def add_technician
    request = Request.find_by id: params[:request_id]
    technician = User.find_by id: params[:technician_id]

    raise ActiveRecord::RecordNotFound if request.nil? or technician.nil?

    request.technician_id = technician.id
    previous_step = request.step
    request.step = Request::PRODUCT_STEPS[:elaboration] if request.step == Request::PRODUCT_STEPS[:in_line]

    if request.save
      if previous_step == Request::PRODUCT_STEPS[:in_line] and request.step == Request::PRODUCT_STEPS[:elaboration]
        hindrance_params = {
          user_id: current_user.id,
          detainee_id: technician.id,
          request_id: request.id
        }
        HindrancesHelper.create_hindrance hindrance_params
      end

      interaction_params = {
        current: 'request',
        content: "O técnico <b>#{technician.name}</b> foi alocado para o pedido",
        request_id: params[:request_id],
        request_type: request.request_type
      }

      InteractionHelper.create 'allocated', interaction_params

      interaction_params = {
        current: 'request',
        content: "O pedido entrou na etapa de <b>#{InteractionHelper::INTERACTION[request.current_stage.to_sym]}</b>",
        owner_id: current_user.id,
        request_id: request.id,
        request_type: request.request_type
      }

      InteractionHelper.create request.current_stage, interaction_params

      if previous_step == 1 and request.step == 2
        request.hindrances.each do |hindrance|
          if hindrance.detainee.role?(User::ROLES[:technical_manager]) and request.technician != hindrance.detainee
            hindrance.destroy
          end
        end
      end

      head :ok
    else
      head :internal_server_error
    end
  end

  def get_request_infos
    request = Request.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    request_json = {}
    request_json['id'] = request.get_request_code
    request_json['raw_id'] = request.id
    request_json['enterprise_name'] = request.enterprise.name
    request_json['truncated_enterprise_name'] = request.enterprise.name.length > 23 ? request.enterprise.name.first(23) + '...' : request.enterprise.name
    request_json['request_type'] = request.request_type
    request_json['step'] = request.step
    request_json['total_time'] = request.elapsed_time_since_created
    request_json['consultant_name'] = request.user&.name
    request_json['consultant_initials'] = request.user&.get_initials
    request_json['consultant_color'] = request.user&.get_color
    request_json['technician_name'] = request.technician&.name
    request_json['technician_color'] = request.technician&.get_color
    request_json['technician_initials'] = request.technician&.get_initials
    request_json['detainees'] = []
    request_json['values'] = build_request_values(request)
    request_json['title'] = request.title
    request_json['calculate_priority'] = request.calculate_priority
    request_json['calculate_priority_percentage'] = "#{(request.calculate_priority_percentage * 100).to_i}%"
    request_json['calculated_revenue'] = number_to_currency(request.calculate_request_revenue)
    request_json['is_proposal_present'] = request.request_proposals.size > 0
    request_json['is_proposal_approved'] = request.request_proposals.exists?(status: 'approved')
    request_json['is_request_full_billed'] = request.is_request_billed?
    request_json['billed_started'] = request.request_installments.exists?(is_billed: true)
    request_json['is_active'] = request.is_active
    request_json['is_payment_complete'] = request.request_installments.empty? ? !request.request_installments.exists?(is_paid: false) : false
    request_json['products'] = []
    request_json['cause_or_reason'] = []
    request_json['is_qsc_present'] = !request.qsc.empty?
    request_json['is_photos_report_present'] = !request.photos_reports.empty?

    request.request_products.each do |rp|
      request_json['products'] << rp.product.name
    end

    if request.is_stock_replacement
      request_json['cause_or_reason'] << 'Reposição de estoque'
    else
      request_json['cause_or_reason'] = request.cause_or_reason
    end

    users_ids = request.hindrances.where(is_active: true).map(&:user_id)

    User.where(id: users_ids, is_active: true).each do |user|
      request_json['detainees'] << [user.name, user.get_initials, user.id, user.get_color]
    end

    request_json['interactions'] = request.interactions.order(created_at: :asc).map do |interaction|
      {
        "content": interaction.print_interaction
      }
    end

    render json: request_json.as_json
  end

  def update_request_step
    request = Request.find_by id: params[:id]

    raise ActiveRecord::RecordNotFound if request.nil?

    previous_step = request.step
    request.step = params[:step] if params[:step].present?

    if params[:step].to_i != previous_step
      create_step_interaction(request, current_user)
    end

    if request.save
      if (request.step == Request::PRODUCT_STEPS[:finished] and request.request_type == 'product') or (request.step == Request::SERVICES_STEPS[:finished] and request.request_type == 'service')
        request.hindrances.update(is_active: false)
      end

      head :ok
    else
      head :internal_server_error
    end
  end

  def create_step_interaction request, user

    interaction_params = {
      current: 'request',
      content: "#{user.name} alterou a etapa do pedido para <b>#{InteractionHelper::INTERACTION[request.current_stage.to_sym]}</b>",
      owner_id: user.id,
      request_id: request.id,
      request_type: request.request_type
    }

    InteractionHelper.create request.current_stage, interaction_params
  end

  def create_comment_interaction
    interaction_params = {
      current: 'request',
      content: params[:content],
      request_id: params[:request][:id],
      owner_id: current_user.id
    }

    interaction_params[:interaction_attachment] = params[:interaction_attachment] if params[:interaction_attachment]

    InteractionHelper.create params[:interaction_type], interaction_params

    head 200
  end

  def upload_file
    request = Request.find_by id: params[:request_id]
    raise ActiveRecord::RecordNotFound if request.nil?

    if request.files.attach(params[:files]) and request.save
      head :ok
    else
      head :internal_server_error
    end
  end

  def get_request_files
    request = Request.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    files_json = []

    all_blobs = {}
    all_blobs['Mem. Cálculo'] = request.calculation_memorials unless current_user.role?(User::ROLES[:service])
    all_blobs['Rel. 3 Fotos'] = request.photos_reports
    all_blobs['Procedimento'] = request.procedures
    all_blobs['Atest. Sucesso'] = request.success_certificates
    all_blobs['Atest. Execução'] = request.execution_certificates
    all_blobs['FS'] = request.fs
    all_blobs['QSC'] = request.qsc
    all_blobs['RDO'] = request.rdo
    all_blobs['Arquivo Financeiro'] = request.financial_files unless current_user.role?(User::ROLES[:service])
    all_blobs['Outros'] = request.files

    all_blobs.each do |type, attachments|
      attachments.each do |attachment|
        current_attachment = {}
        current_attachment['filename'] = attachment.blob.filename
        current_attachment['date'] = attachment.blob.created_at.strftime("%d/%m/%y %H:%M")
        current_attachment['size'] = number_to_human_size(attachment.blob.byte_size)
        current_attachment['blob_path'] = rails_blob_path(attachment.blob, disposition: "attachment")
        current_attachment['blob_id'] = attachment.id
        current_attachment['attachment_type'] = type
        files_json << current_attachment
      end
    end

    render json: files_json.as_json, status: :ok
  end

  def remove_file
    blob = ActiveStorage::Attachment.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if blob.nil?


    if blob.name == 'photos_reports' and blob.record.photos_reports.size == 1
      requirement = Requirement.find_by_title 'Relatório Técnico'
      request = blob.record

      user_score = UserScore.where(request_id: request.id, requirement_id: requirement.id).last
      user_score.destroy if user_score
    end

    if blob.name == 'success_certificates' and blob.record.success_certificates.size == 1
      requirement = Requirement.find_by_title 'Atestado com custo benefício'
      request = blob.record

      user_score = UserScore.where(request_id: request.id, requirement_id: requirement.id).last
      user_score.destroy if user_score
    end

    if blob.name == 'execution_certificates' and blob.record.execution_certificates.size == 1
      requirement = Requirement.find_by_title 'Atestado'
      request = blob.record

      user_score = UserScore.where(request_id: request.id, requirement_id: requirement.id).last
      user_score.destroy if user_score
    end

    if blob.name == 'qsc' and blob.record.qsc.size == 1
      requirement = Requirement.find_by_title 'QSC'
      request = blob.record

      user_score = UserScore.where(request_id: request.id, requirement_id: requirement.id).last
      user_score.destroy if user_score
    end

    if blob.name == 'fs' and blob.record.fs.size == 1
      requirement = Requirement.find_by_title 'FS'
      request = blob.record

      user_score = UserScore.where(request_id: request.id, requirement_id: requirement.id).last
      user_score.destroy if user_score
    end

    blob.purge
  end

  def get_interactions
    request = Request.find_by id: params[:id]

    raise ActiveRecord::RecordNotFound if request.nil?

    request_json                 = {}
    request_json['interactions'] = request.interactions.map do |interaction|
      {
        "content": interaction.print_interaction
      }
    end

    render json: request_json
  end

  def get_enteprise_requests
    requests = search_requests params

    requests_json = []
    requests.first(9).each do |request|
      current_request = {}
      current_request['raw_id'] = request.id
      current_request['id'] = request.get_request_code
      current_request['datainees'] = request.detainees_number
      current_request['title'] = request.title
      current_request['calculate_priority'] = request.calculate_priority
      current_request['calculate_priority_percentage'] = "#{(request.calculate_priority_percentage * 100).to_i}%"
      current_request['calculated_revenue'] = number_to_currency(request.calculate_request_revenue)
      current_request['proposal_code'] = request.proposal_code ? request.proposal_code : ''
      requests_json << current_request
    end

    render json: requests_json
  end


  def index_database
    @title = "Hita CRM | Biblioteca"
    @filters = [
      ['Causa do problema', 'cause_or_reason'], ['Tipo de equipamento', 'equipment_type'], ['TAG', 'tag'],
      ['Substrato', 'substratum'], ['Fluido e Concentração', 'fluids'], ['Temp Cº', 'temperature'],
      ['Pressão', 'pressure'], ['Tipo de Preparação', 'surface_preparation'], ['Empresa', 'enterprise'], ['Estado', 'state'], ['Cidade', 'city'],
      ['Segmento', 'segment'], ['Solução', 'solutions'], ['Nº da Oportunidade', 'request_code']
    ].sort

    @fluid_range = [
      ['0% < x < 5%', '0/5'], ['5% < x < 100%', '5/100'], ['0% < x < 20%', '0/20'], ['20% < x < 100%', '20/100'],
      ['0% < x < 50%', '0/50'], ['50% < x < 100%', '50/100'], ['0% < x < 75%', '0/75'], ['75% < x < 100%', '75/100']
    ]

    if params[:filter].present? and params[:filter_value].present?
      @filter       = params[:filter]
      @filter_value = params[:filter_value]
    end
  end

  def get_filter_values
    filter_params = {}
    search_obj    = {}

    if current_user.role?(User::ROLES[:consultant])
      search_obj[:id] = current_user.enterprises.pluck(:id)
    elsif current_user.role?(User::ROLES[:regional_coordinator])
      search_obj[:id] = current_user.get_enterprises_team.pluck(:id)
    end

    if params[:filter] == 'enterprise'
      filter_params['filter_type'] = 'enterprise_name'
      filter_params['values']      = Enterprise.where(search_obj).pluck(:name).uniq.sort
    elsif params[:filter] == 'state'
      filter_params['filter_type'] = 'enterprise_state'
      filter_params['values']      = Enterprise.where(search_obj).pluck(:state).uniq.sort
    elsif params[:filter] == 'city'
      filter_params['filter_type'] = 'enterprise_city'
      filter_params['values']      = Enterprise.where(search_obj).pluck(:city).uniq.reject(&:blank?).sort
    elsif params[:filter] == 'segment'
      filter_params['filter_type'] = 'enterprise_industry_sector'
      filter_params['values']      = Enterprise.where(search_obj).pluck(:industry_sector).uniq.sort
    elsif params[:filter] == 'equipment_type'
      filter_params['filter_type'] = 'equipment_type'
      filter_params['values']      = Equipment.pluck(:name).uniq.sort
    elsif params[:filter] == 'cause_or_reason'
      search_obj = {}

      if current_user.role?(User::ROLES[:consultant])
        search_obj[:enterprise_id] = current_user.enterprises.pluck(:id)
      elsif current_user.role?(User::ROLES[:regional_coordinator])
        search_obj[:enterprise_id] = current_user.get_enterprises_team.pluck(:id)
      end

      cause_or_reason = Request.where(search_obj).where.not(cause_or_reason: nil).pluck(:cause_or_reason).flatten.uniq.sort

      if cause_or_reason.present?
        filter_params['filter_type'] = 'cause_or_reason'
        filter_params['values']      = cause_or_reason
      end
    elsif params[:filter] == 'solutions'
      search_obj = {}

      if current_user.role?(User::ROLES[:consultant])
        search_obj[:enterprise_id] = current_user.enterprises.pluck(:id)
      elsif current_user.role?(User::ROLES[:regional_coordinator])
        search_obj[:enterprise_id] = current_user.get_enterprises_team.pluck(:id)
      end

      solutions = Request.where(search_obj).where.not(solutions: nil).pluck(:solutions).flatten.uniq.sort

      if solutions.present?
        filter_params['filter_type'] = 'solutions'
        filter_params['values']      = solutions
      end
    elsif params[:filter] == 'substratum'
      search_obj = {}

      if current_user.role?(User::ROLES[:consultant])
        search_obj[:enterprise_id] = current_user.enterprises.pluck(:id)
      elsif current_user.role?(User::ROLES[:regional_coordinator])
        search_obj[:enterprise_id] = current_user.get_enterprises_team.pluck(:id)
      end

      substratum = Request.where(search_obj).where.not(substratum: nil).pluck(:substratum).flatten.uniq.sort

      if substratum.present?
        filter_params['filter_type'] = 'substratum'
        filter_params['values']      = substratum
      end
    elsif params[:filter] == 'surface_preparation'
      search_obj = {}

      if current_user.role?(User::ROLES[:consultant])
        search_obj[:enterprise_id] = current_user.enterprises.pluck(:id)
      elsif current_user.role?(User::ROLES[:regional_coordinator])
        search_obj[:enterprise_id] = current_user.get_enterprises_team.pluck(:id)
      end

      surface_preparation = Request.where(search_obj).where.not(surface_preparation: nil).pluck(:surface_preparation).flatten.uniq.sort

      if surface_preparation.present?
        filter_params['filter_type'] = 'surface_preparation'
        filter_params['values']      = surface_preparation
      end
    elsif params[:filter] == 'fluids'
      search_obj = {}

      if current_user.role?(User::ROLES[:consultant])
        search_obj[:enterprise_id] = current_user.enterprises.pluck(:id)
      elsif current_user.role?(User::ROLES[:regional_coordinator])
        search_obj[:enterprise_id] = current_user.get_enterprises_team.pluck(:id)
      end

      fluids = []

      Request.where(search_obj).where.not(fluids: nil).pluck(:fluids).flatten.uniq.each do |f|
        fluids << f.split('/').first
      end

      fluids.uniq!

      if fluids.present?
        filter_params['filter_type'] = 'fluids'
        filter_params['values']      = fluids
      end
    elsif params[:filter] == 'pressure'
      pressure = [
        ['x < 0', '-1199/0'], ['0 < x < 10', '0/10'], ['10 < x < 1200', '10/1200'], ['0 < x < 25', '0/25'],
        ['25 < x < 1200', '25/1200'], ['0 < x < 50', '0/50'], ['50 < x < 1200', '50/1200'], ['0 < x < 100', '0/100'],
        ['100 < x < 1200', '100/1200']
      ]

      if pressure.present?
        filter_params['filter_type'] = 'pressure'
        filter_params['values']      = pressure
      end
    elsif params[:filter] == 'temperature'
      temperature = [
        ['x < 0', '-1199/-150'], ['0 < x < 20', '0/20'], ['0 < x < 55', '0/55'], ['55 < x < 90', '55/90'],
        ['90 < x < 120', '90/120'], ['0 < x < 90', '0/90'], ['0 < x < 120', '0/120'], ['120 < x < 400', '120/400'],
        ['0 < x < 150', '0/150'], ['150 < x < 400', '150/400']
      ]

      if temperature.present?
        filter_params['filter_type'] = 'temperature'
        filter_params['values']      = temperature
      end
    end

    render json: filter_params
  end

  def filter_requests_database
    params[:page] ||= 1

    if params[:filter].present?
      enterprise_ids = []

      if params[:filter][:enterprise].present?
        enterprise_ids = Enterprise.where(name: params[:filter][:enterprise]).pluck(:id).uniq
      else
        if current_user.role?(User::ROLES[:consultant])
          enterprise_ids = current_user.enterprises.pluck(:id)
        elsif current_user.role?(User::ROLES[:regional_coordinator])
          enterprise_ids = current_user.get_enterprises_team.pluck(:id)
        end
      end

      search = Request.search do
        all_of do
          with :cause_or_reason, params[:filter][:cause_or_reason]            if params[:filter][:cause_or_reason].present?
          with :substratum, params[:filter][:substratum]                      if params[:filter][:substratum].present?
          with :surface_preparation, params[:filter][:surface_preparation]    if params[:filter][:surface_preparation].present?
          with :solutions, params[:filter][:solutions]                        if params[:filter][:solutions].present?
          with :equipment, params[:filter][:equipment_type]                   if params[:filter][:equipment_type].present?
          with :request_code, params[:filter][:request_code]                  if params[:filter][:request_code].present?
          with :is_draft, false

          if params[:filter][:fluids].present?
            params[:filter][:fluids].each_with_index do |fluid, i|
              if params[:filter][:fluid_range][i].present?
                fluid_range_splitted = params[:filter][:fluid_range][i].split("/").map(&:to_i)

                a = (fluid_range_splitted[0]..fluid_range_splitted[1]).map {|c| "#{fluid}/#{c}"}
                any_of do
                  a.each do |f|
                    with(:fluids).equal_to(f)
                  end
                end
              else
                a = (0..100).map {|c| "#{fluid}/#{c}"}
                with(:fluids, a)
              end
            end
          end

          if params[:filter][:pressure].present?
            params[:filter][:pressure].each do |pressure|
              pressure_splitted = pressure.split('/').map(&:to_f)

              any_of do
                with(:pressure_opr, pressure_splitted[0]..pressure_splitted[1])
                with(:pressure_proj, pressure_splitted[0]..pressure_splitted[1])
              end
            end
          end

          if params[:filter][:temperature].present?
            params[:filter][:temperature].each do |temperature|
              temperature_splitted = temperature.split('/').map(&:to_f)

              any_of do
                with(:temperature_opr, temperature_splitted[0]..temperature_splitted[1])
                with(:temperature_proj, temperature_splitted[0]..temperature_splitted[1])
              end
            end
          end

          # Enterprise attrs

          with :enterprise_segment, params[:filter][:segment]   if params[:filter][:segment].present?
          with :enterprise_state, params[:filter][:state]       if params[:filter][:state].present?
          with :enterprise_city, params[:filter][:city]         if params[:filter][:city].present?
          with :enterprise_id, enterprise_ids
        end

        paginate :page => params[:page], :per_page => 50
        order_by :created_at, :desc
      end

      @requests = search.results
      @total    = search.total
    else
      if current_user.role?(User::ROLES[:consultant])
        enterprise_ids = current_user.enterprises.pluck(:id)
      elsif current_user.role?(User::ROLES[:regional_coordinator])
        enterprise_ids = current_user.get_enterprises_team.pluck(:id)
      elsif current_user.role?(User::ROLES[:admin]) || current_user.role?(User::ROLES[:financial])
        enterprise_ids = Enterprise.pluck(:id)
      end

      search = Request.search do
        with :enterprise_id, enterprise_ids
        with :is_draft, false
        paginate :page => params[:page], :per_page => 50
        order_by :created_at, :desc
      end

      @requests = search.results
      @total    = search.total
    end
  end

  def generate_proposal_code request, products
    equipment = request.equipment

    product = if products and products.size > 0
                aux = products.first
                product = Product.find_by code: aux['code']
              else
                nil
              end

    if equipment.nil? and request.is_stock_replacement
      return "REPO" if product.nil?

      if product.name.downcase.include? 'belzona'
        splitted_name = product.name.split(' ')[1]
        return "REPO_B#{splitted_name[0..3]}" if splitted_name
        return "REPO_B0000"

      elsif product.name.downcase.include? 'gaxeta slade'
        splitted_name = product.name.split(' ')[1]
        return "REPO_S#{splitted_name[0..3]}" if splitted_name
        return "REPO_S0000"

        return "REPO_#{product.name[0..4]}"
      else
        return "REPO_#{product.name[0..4]}"
      end

    elsif equipment and product
      if product.name.downcase.include? 'belzona'
        splitted_name = product.name.split(' ')[1]
        return "#{equipment.name[0..5]}_B#{splitted_name[0..3]}" if splitted_name
        return "#{equipment.name[0..5]}_B0000"

      elsif product.name.downcase.include? 'gaxeta slade'
        splitted_name = product.name.split(' ')[1]
        return "#{equipment.name}_S#{splitted_name[0..3]}" if splitted_name
        return "#{equipment.name}_S0000"

      else
        return "#{equipment.name[0..5]}_#{product.name[0..4]}"
      end
    elsif equipment.nil? and !request.is_stock_replacement
      return ""
    else
      return "#{equipment.name[0..5].upcase.gsub(' ', '_')}"
    end

    return ""
  end

  def store_request_products_with_shipping request, products, total_shipping
    products.each_with_index do |product, index|
      products[index] = JSON.parse(product)
    end

    total_products_price = 0
    products.each_with_index do |product, index|

      hita_product = Product.find_by code: product['code']
      next if hita_product.nil?

      enterprise_price_table = request.enterprise.price_table

      if products[index]['personalized_price'].present?
        product_price = products[index]['personalized_price'].to_f
      else
        product_price = hita_product.get_product_price(enterprise_price_table) * product['quantity'].to_f
      end

      products[index]['hita_product_id'] = hita_product.id
      products[index]['product_price'] = product_price
      total_products_price += product_price
    end

    products.each do |product|

      if request.shipping_type == 'total'
        if product['personalized_price']
          product['shipping'] = ((product['personalized_price']/total_products_price.to_f) * total_shipping).round
        else
          product['shipping'] = ((product['product_price'] /total_products_price.to_f) * total_shipping).round
        end
      elsif request.shipping_type == 'none'
        product['shipping'] = 0
      else
        product['shipping'] = convert_br_currency_to_float(product['shipping'])
      end

      product['shipping'] = 0 if product['shipping'].blank?

      product = RequestProduct.new(
        request_id: request.id,
        product_id: product['hita_product_id'],
        calculated_price: product['product_price'],
        shipping_price: (request.shipping_type == 'total' ? product['shipping'] : convert_br_currency_to_float(product['shipping'])),
        product_quantity: product['quantity'],
        price_with_discount: (product['personalized_price'].present? ? product['personalized_price'] : nil)
      )

      product.save
    end

    return total_products_price + request.request_products.sum(&:shipping_price).to_f
  end

  def technician_request_validation
    request = Request.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    if request.is_valid.nil?
      user_score_params = {
        requirement_title: 'Solicitações via Sistema',
        current_user_id: request.user.id,
        current_date: Date.today
      }

      UserScoresHelper.create user_score_params
    end

    if request.toggle!(:is_valid)
      if request.is_valid
        interaction_params = {
          owner_id: current_user.id,
          request_id: request.id,
          current: 'request'
        }

        InteractionHelper.create 'validated_premises', interaction_params
      end

      render json: { is_valid: request.is_valid }, status: :ok
    else
      render json: { is_valid: request.is_valid }, status: :internal_server_error
    end
  end

  def destroy_draft
    request = Request.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    if current_user.id != request.user.id

      flash[:alert] = 'Não foi possível apagar este rascunho.'
      return redirect_to see_drafts_path
    end

    if request.destroy
      flash[:notice] = 'O rascunho foi apagado com sucesso.'
    else
      flash[:alert] = 'O rascunho não pode ser apagado.'
    end

    redirect_to see_drafts_path
  end

  def upload_specific_file
    request = Request.find_by id: params[:request][:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    errors = []

    if params[:request][:proposal].present?

      previous_proposal = request.request_proposals.first
      if previous_proposal and !previous_proposal.file.attached?
        previous_proposal.purge
      end

      request_proposal = RequestProposal.new
      request_proposal.request = request
      request_proposal.save

      if request_proposal.save
        unless request_proposal.file.attach(params[:request][:proposal])
          errors <<
          { message:'Não foi possivel salvar o arquivo da proposta', file_type: 'proposal' }
        end
      else
        errors <<
        { message:'Não foi possivel salvar a proposta', file_type: 'proposal' }
      end
    end

    if params[:request][:calculation_memorial].present?
      errors <<
      { message:'Não foi possivel salvar o memorial de cálculo.', file_type: 'calculation_memorial' } unless request.calculation_memorials.attach(params[:request][:calculation_memorial])
    end

    if params[:request][:photos_report].present?

      is_first = request.photos_reports.empty?

      if request.photos_reports.attach(params[:request][:photos_report])
        if current_user.role?(User::ROLES[:consultant]) and is_first
          user_score_params = {
            requirement_title: 'Relatório Técnico',
            current_user_id: current_user.id,
            current_date: Date.today,
            request_id: request.id
          }

          UserScoresHelper.create user_score_params
        end
      else
        errors <<
        { message:'Não foi possivel salvar o relatório de 3 fotos.', file_type: 'photos_report' } unless request.photos_reports.attach(params[:request][:photos_report])
      end
    end

    if params[:request][:procedure].present?
      errors <<
      { message:'Não foi possivel salvar o procedimento.', file_type: 'procedure' } unless request.procedures.attach(params[:request][:procedure])
    end

    if params[:request][:success_certificate].present?

      is_first = request.success_certificates.empty?

      if request.success_certificates.attach(params[:request][:success_certificate])
        if current_user.role?(User::ROLES[:consultant]) and is_first
          user_score_params = {
            requirement_title: 'Atestado com custo benefício',
            current_user_id: current_user.id,
            current_date: Date.today,
            request_id: request.id
          }

          UserScoresHelper.create user_score_params
        end
      else
        errors <<
        { message:'Não foi possivel salvar o atestado de sucesso.', file_type: 'success_certificate' } unless request.success_certificates.attach(params[:request][:success_certificate])
      end
    end

    if params[:request][:execution_certificate].present?

      is_first = request.execution_certificates.empty?

      if request.execution_certificates.attach(params[:request][:execution_certificate])
        if current_user.role?(User::ROLES[:consultant]) and is_first
          user_score_params = {
            requirement_title: 'Atestado',
            current_user_id: current_user.id,
            current_date: Date.today,
            request_id: request.id
          }

          UserScoresHelper.create user_score_params
        end
      else
        errors <<
        { message:'Não foi possivel salvar o atestado de execução.', file_type: 'execution_certificate' } unless request.execution_certificates.attach(params[:request][:execution_certificate])
      end
    end

    if params[:request][:qsc].present?

      is_first = request.qsc.empty?

      if request.qsc.attach(params[:request][:qsc])
        if current_user.role?(User::ROLES[:consultant]) and is_first
          user_score_params = {
            requirement_title: 'QSC',
            current_user_id: current_user.id,
            current_date: Date.today,
            request_id: request.id
          }

          UserScoresHelper.create user_score_params
        end
      else
        errors <<
        { message:'Não foi possivel salvar o QSC.', file_type: 'qsc' } unless request.qsc.attach(params[:request][:qsc])
      end
    end

    if params[:request][:fs].present?

      is_first = request.fs.empty?

      if request.fs.attach(params[:request][:fs])
        if current_user.role?(User::ROLES[:consultant]) and is_first
          user_score_params = {
            requirement_title: 'FS',
            current_user_id: current_user.id,
            current_date: Date.today,
            request_id: request.id
          }

          UserScoresHelper.create user_score_params
        end
      else
        errors <<
        { message:'Não foi possivel salvar o FS.', file_type: 'fs' } unless request.fs.attach(params[:request][:fs])
      end
    end

    if params[:request][:rdo].present?
      errors <<
      { message:'Não foi possivel salvar o RDO.', file_type: 'rdo' } unless request.rdo.attach(params[:request][:rdo])
    end

    if params[:request][:financial_files].present?
      errors <<
      { message:'Não foi possivel salvar o arquivo financeiro.', file_type: 'financial_file' } unless request.financial_files.attach(params[:request][:financial_files])
    end

    if errors.length > 0
      render json: errors, status: :internal_server_error
    else
      render json: {}, status: :ok
    end
  end

  def build_request_values request
    values = {}
    values[:real] = {
      request: number_to_currency(request.calculate_request_revenue).remove('R$ '),
      loose: number_to_currency(request.real_loose_value).remove('R$ ')
    }

    total_products_value = 0
    request.request_products.each do |product|
      total_products_value += product.price_with_discount ? product.price_with_discount.to_f : product.calculated_price.to_f
    end

    values[:real][:products] = number_to_currency(total_products_value).remove('R$ ')
    values[:real][:service] = request.value_estimation ? number_to_currency(request.value_estimation).remove('R$ ') : '0,00'

    values[:planned] = {
      request: number_to_currency(request.planned_request_value).remove('R$ '),
      products: number_to_currency(request.planned_products_value).remove('R$ '),
      service: number_to_currency(request.planned_service_value).remove('R$ '),
      loose: number_to_currency(request.planned_loose_value).remove('R$ ')
    }

    return values
  end

  def update_request_values
    request = Request.find_by id: params[:request_id]
    raise ActiveRecord::RecordNotFound if request.nil?

    if params[:request_value_type] == 'planned'
      request.planned_products_value = convert_br_currency_to_float(params[:planned_value][:products])
      request.planned_loose_value    = convert_br_currency_to_float(params[:planned_value][:loose])
      request.planned_service_value  = convert_br_currency_to_float(params[:planned_value][:service])
      request.planned_request_value  = convert_br_currency_to_float(request.planned_products_value + request.planned_service_value)
    else
      request.real_loose_value = convert_br_currency_to_float(params[:real_value][:loose])
    end

    if request.save
      head :ok
    else
      head :internal_server_error
    end
  end

  def get_request_values
    request = Request.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    render json: build_request_values(request).as_json
  end

  def archive_request
    request = Request.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    request.is_active = false

    if request.save
      request.hindrances.destroy_all
      head :ok
    else
      head :internal_server_error
    end
  end

  def update_request_enterprise
    request = Request.find_by id: params[:update_enterprise][:request_id]
    raise ActiveRecord::RecordNotFound if request.nil?

    enterprise = Enterprise.find_by id: params[:update_enterprise][:enterprise_id]
    raise ActiveRecord::RecordNotFound if enterprise.nil?

    collaborator = Collaborator.find_by id: params[:update_enterprise][:collaborator_id]
    raise ActiveRecord::RecordNotFound if collaborator.nil?

    old_enterprise = request.enterprise
    new_enterprise = enterprise

    if old_enterprise == new_enterprise
      return head :ok
    end

    request.enterprise = enterprise
    request.collaborator = collaborator

    if request.save
      request.request_installments.each do |installment|
        installment.reports.update(enterprise_id: enterprise.id)
      end

      request_revenue = request.request_installments.where(is_billed: true).sum(:value)

      old_enterprise.revenue = old_enterprise.revenue - request_revenue
      old_enterprise.save

      new_enterprise.revenue = new_enterprise.revenue + request_revenue
      new_enterprise.save

      head :ok
    else
      head :internal_server_error
    end
  end

  def get_enterprise_id

   @request = Request.find_by id: params[:request_id]

   @enterprise = Enterprise.find_by id: @request.enterprise_id

   render json: @enterprise
   
  end

  def getrequestCode
    @request = Request.find_by! id: params[:request_id]
    render json: @request   
  end

  

end
