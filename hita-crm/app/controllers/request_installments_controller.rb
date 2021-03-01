class RequestInstallmentsController < ApplicationController
  include ReportsHelper

  def get_request_installments_infos
    request = Request.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    installments_json = {
      is_billed: request.is_billed,
      request_type: request.request_type,
      request_step: request.step,
      calculated_revenue: request.calculate_request_revenue,
      installments: []
    }

    request.request_installments.each do |installment|
      current_installment = {}
      current_installment['value'] = number_to_currency(installment.value.to_f).remove("R$ ")
      current_installment['date'] = installment.date.strftime("%d/%m/%Y")
      current_installment['is_billed'] = installment.is_billed
      current_installment['is_paid'] = installment.is_paid
      installments_json[:installments] << current_installment

      if installment.is_billed
        installments_json[:block_unsplit] = true
      end
    end

    render json: installments_json.as_json, status: :ok
  end

  def save_installments

    #ERRO AO CADASTRAR REQUEST COMEÇA AQUI!
    #PARAMETRO ID IGUAL A NULO!

    request = Request.find_by id: params[:request_id]
    #request = Request.find_by id: params[:id]

    # NO FRONT: _installmentes_modal.html.erb, Linha 1176 [ save_installments_url ]
    # REQUEST_ID É PASSADO
    
    next_step = 0

    raise ActiveRecord::RecordNotFound if request.nil?

    if params[:removed_installments].present?
      create_interaction_for_removed_installment(request, params[:removed_installments])
    end

    enterprise = request.enterprise
    enterprise.revenue -= request.request_installments.where(is_billed: true).sum(:value)
    enterprise.save

    request.request_installments.destroy_all
    installments_length = params[:installments].size
    
    params[:installments].each do |installment|
      parsed_installment = JSON.parse(installment)

      installment = RequestInstallment.new
      installment.request = request
      installment.value = convert_br_currency_to_float(parsed_installment['value'])
      installment.date = Date.parse(parsed_installment['date'])
      installment.is_billed = parsed_installment['is_billed']
      installment.is_paid = parsed_installment['is_paid']

      if installment.save
        create_installment_reports(request, installment, installments_length) if installment.is_billed
        recalculate_user_scores_for_enterprise request, request.enterprise, installment.date.month, installment.date.year
      else
        # return render json: { message: 'Erro ao salvar parcela.'}, status: :internal_server_error
      end
    end

    if ((request.step == 4 and request.request_type == 'product') or (request.step == 6 and request.request_type == 'service'))
      next_step = request.step + 1
    end

    is_payment_complete = request.request_installments.empty? ? !request.request_installments.exists?(is_paid: false) : false

    if (((request.step == 6 and request.request_type == 'product') or (request.step == 7 and request.request_type == 'service')) and is_payment_complete)
      next_step = request.step + 1
    end

    return render json: { next_step: next_step }, status: :ok
  end

  def create_installment_reports request, installment, installments_length

    create_enterprise_report(request, installment.value, installment.date, installment)

    shipping_per_installment = request.request_products.sum(:shipping_price).to_f / installments_length
    service_per_installment  = request.value_estimation.to_f / installments_length

    total_products = request.request_products.sum(:product_quantity).to_f

    value_without_shipping             = installment.value - shipping_per_installment
    value_without_service_and_shipping = value_without_shipping - service_per_installment

    request.request_products.each do |product|
      value_for_report = value_without_service_and_shipping * product.product_quantity / total_products
      create_product_report(request, product, value_for_report, installment.date, installment)
    end

    if request.request_type == 'service'
      create_service_report(request, service_per_installment, installment.date, installment)
    end

    create_shipping_report(request, shipping_per_installment, installment.date, installment) if shipping_per_installment != 0
  end

  def create_interaction_for_removed_installment request, installments
    installments.each do |installment|
      installment = JSON.parse(installment)

      interaction_params = {
        current: 'request',
        content: "Uma parcela de valor <span class='bold'>#{installment['value']}</span> para o dia #{installment['date']} foi cancelada.",
        owner_id: current_user.id,
        request_type: request.request_type,
        request_id: request.id
      }

      InteractionHelper.create 'installment_removed', interaction_params
    end
  end

  def create_enterprise_report request, value, date, installment
    report_enterprise_params = {
      amount: value,
      year: date.year,
      month_number: date.month,
      report_type: 'accomplished',
      enterprise_id: request.enterprise.id,
      request_id: request.id,
      installment_id: installment.id 
    }

    ReportsHelper.create(report_enterprise_params)

    enterprise = request.enterprise
    logger.debug "Adicionando o valor faturado"
    enterprise.revenue += value
    enterprise.save
  end

  def create_product_report request, product, value, date, installment
    report_params = {
      product_id: product.product.id,
      amount: value,
      year: date.year,
      month_number: date.month,
      enterprise_id: request.enterprise.id,
      request_id: request.id,
      installment_id: installment.id
    }

    ReportsHelper.create_product(report_params)
  end

  def create_shipping_report request, shipping_price, date, installment
    shipping_params = {
      amount: shipping_price,
      year: date.year,
      month_number: date.month,
      request_id: request.id,
      installment_id: installment.id
    }

    ReportsHelper.create_shipping(shipping_params)
  end

  def create_service_report request, service_value, date, installment
    service_params = {
      amount: service_value,
      year: date.year,
      month_number: date.month,
      request_id: request.id,
      installment_id: installment.id
    }

    ReportsHelper.create_service(service_params)
  end

  def recalculate_user_scores_for_enterprise request, enterprise, month_number, year

    requirement = Requirement.find_by_title 'Meta Anual'
    UserScore.where('extract(year from period) = ?', year)
             .where(requirement_id: requirement.id, user_id: enterprise.user.id).destroy_all

    goal = enterprise.get_percentage_planning_year(year).to_f

    if goal >= 100.0
      user_score_params = {
        current_user_id: enterprise.user.id,
        requirement_title: 'Meta Anual',
        current_date: Date.new.change(:month => month_number, :year => year)
      }

      UserScoresHelper.create user_score_params
    end

    # 'Líder de Vendas Mensal' REGULARIDADE MENSAL

    requirement = Requirement.find_by_title 'Regularidade Mensal'
    UserScore.where('extract(year from period) = ? AND extract(month from period) = ?', year, month_number)
             .where(requirement_id: requirement.id, user_id: enterprise.user.id).destroy_all

    goal = enterprise.get_percentage_planning(month_number, year).to_f

    if goal >= 100.0
      user_score_params = {
        current_user_id: enterprise.user.id,
        requirement_title: 'Regularidade Mensal',
        current_date: Date.new.change(:month => month_number, :year => year)
      }

      UserScoresHelper.create user_score_params
    end

    # 'Líder de Vendas Mensal' LÍDER DE VENDAS MENSAL

    requirement = Requirement.find_by_title 'Líder de Vendas Mensal'
    UserScore.where('extract(year from period) = ? and extract(month from period) = ?', year, month_number)
             .where(requirement_id: requirement.id).destroy_all

    max_invoicing = ReportsHelper.get_highest_monthly_invoicing(month_number, year)

    User.all.each do |user|
      max_invoicing_user = ReportsHelper.get_highest_monthly_invoicing(month_number, year, user.id)

      if max_invoicing_user > 0
        user_score_params = {
          current_user_id: user.id,
          requirement_title: 'Líder de Vendas Mensal',
          current_date: Date.new.change(:month => month_number, :year => year),
          score: (max_invoicing_user.to_f / max_invoicing) * 1.5
        }

        UserScoresHelper.create user_score_params
      end
    end
  end
end