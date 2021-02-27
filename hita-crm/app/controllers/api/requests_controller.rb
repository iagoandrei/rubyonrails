class Api::RequestsController < Api::ApiController

  def show_all
    if params[:datetime].present?
      begin
        datetime = DateTime.parse(params[:datetime])
      rescue ArgumentError
        return render json: { error: true, message: 'Ocorreu um erro ao identificar a data.', code: 500 }, status: :internal_server_error
      rescue
        return render json: { error: true, message: 'Ocorreu um erro ao identificar a data.', code: 500 }, status: :internal_server_error
      end

      @requests = Request.where('user_id = ? AND updated_at >= ?', current_user.id, datetime).where(is_active: true)
    else
      @requests = Request.where('user_id = ?', current_user.id).where(is_active: true)
    end
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

    return render json: { id: request.id, message: 'Oportunidade foi criada com sucesso.', request_code: request.get_request_code }
  end

  def update
    request = Request.find_by id: params[:id]

    if request.nil?
      return render json: { error: true, message: 'Oportunidade não encontrada.' }, status: :not_found
    end

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

      interaction_params = {
        owner_id: current_user.id,
        content: "<b>#{current_user.name}</b> solicitou uma nova proposta.",
        request_id: request.id,
        current: 'request'
      }

      InteractionHelper.create 'requested_by', interaction_params
    end

    request.response_time = params[:request_data][:response_time]
    request.shipping_type = params[:request_data][:shipping_type]
    request.shipping_modality = params[:request_data][:shipping_modality]
    request.is_draft = params[:request_data][:is_draft]
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

  def parse_fluid_data data
    parsed_data = data['questions']
    parsed_array = []

    i = 2
    last_fluid = false
    while (parsed_data[i] and !last_fluid)

      current_answer = ''
      current_answer = parsed_data[i-2]['user_answers'][0]['text'] unless parsed_data[i-2]['user_answers'].empty?

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

      RequestProduct.create(
        request_id: request.id,
        product_id: product['hita_product_id'],
        calculated_price: product['product_price'],
        shipping_price: (request.shipping_type == 'total' ? product['shipping'] : convert_br_currency_to_float(product['shipping'])),
        product_quantity: product['quantity'],
        price_with_discount: (product['personalized_price'].present? ? product['personalized_price'] : nil)
      )
    end

    return total_products_price + request.request_products.sum(&:shipping_price).to_f
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
end
