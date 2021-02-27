class FormsController < ApplicationController
  def index
    @title = 'Hita CRM | Formulários'
    @forms = Form.where(form_type: 'form').order(:name)

    if current_user.role?(User::ROLES[:consultant])
      @enterprises = current_user.enterprises.pluck(:name, :id)
    else
      @enterprises = Enterprise.all.order(name: :asc).pluck(:name, :id)
    end
  end

  def index_proposal
    @title = 'Hita CRM | Propostas'
    @forms = Form.where(form_type: 'proposal').order(:name)

    if current_user.role?(User::ROLES[:consultant])
      @enterprises = current_user.enterprises.pluck(:name, :id)
    else
      @enterprises = Enterprise.all.order(name: :asc).pluck(:name, :id)
    end
  end

  def new_form
    @title = 'Hita CRM | Criar Formulários'
    @forms = Form.where(form_type: 'form')
  end

  def new_proposal_form
    @title = 'Hita CRM | Criar Propostas'
    @forms = Form.where(form_type: 'proposal')
  end

  def create
    form = Form.new
    form.name = params[:form][:name]
    form.template.attach params[:form][:file]
    form.form_type = 'form'

    if form.save
      flash[:notice] = 'O formulário foi criado com sucesso'
    else
      flash[:alert] = 'Ocorreu um erro ao criar o formulário'
    end

    redirect_to new_form_url
  end

  def create_proposal
    form = Form.new
    form.name = params[:form][:name]
    form.template.attach params[:form][:file]
    form.form_type = 'proposal'

    if form.save
      flash[:notice] = 'A proposta foi criada com sucesso'
    else
      flash[:alert] = 'Ocorreu um erro ao criar a proposta'
    end

    redirect_to new_proposal_form_url
  end

  def update_template
    form = Form.find_by id: params[:form][:id]
    attached = form.template.attach params[:form][:file]

    if form.form_type and form.form_type == 'proposal'
      if attached
        flash[:notice] = 'A proposta atualizado com sucesso'
      else
        flash[:alert] = 'Ocorreu um erro ao atualizar a proposta'
      end

      redirect_to new_proposal_form_url
    else
      if attached
        flash[:notice] = 'O formulário foi atualizado com sucesso'
      else
        flash[:alert] = 'Ocorreu um erro ao atualizar o formulário'
      end

      redirect_to new_form_url
    end
  end

  def destroy
    form      = Form.find_by id: params[:id]
    form_type = form.form_type

    if form_type and form_type == 'proposal'
      if form&.destroy
        flash[:notice] = 'A proposta foi atualizada com sucesso'
      else
        flash[:alert] = 'Ocorreu um erro ao remover a proposta'
      end

      redirect_to new_proposal_form_url
    else
      if form&.destroy
        flash[:notice] = 'O formulário foi atualizado com sucesso'
      else
        flash[:alert] = 'Ocorreu um erro ao remover o formulário'
      end

      redirect_to new_form_url
    end
  end

  def generate_form
    form = Form.find_by id: params[:form][:id]
    raise ActiveRecord::RecordNotFound if form.nil?

    referer = request.referer.nil? ? nil : request.referer.split('/').last

    request = Request.find_by id: params[:form][:request_id]
    raise ActiveRecord::RecordNotFound if request.nil?

    unless request.is_valid
      flash[:alert] = 'Não é possível gerar formulários ou propostas de pedidos com premissas não validadas.'

      return redirect_to forms_proposal_index_url if referer == 'gerar_proposta'

      return redirect_to forms_index_url
    end

    template_file = ActiveStorage::Blob.service.send(:path_for, form.template.blob.key)
    template = Sablon.template(template_file)

    context = build_hita_keys(request)

    form_keys = process_quiz_answers(request)
    context = form_keys.merge(context)

    processed = template.render_to_string(context)
    send_data(processed, filename: "#{form.template.blob.filename}")
  end

  def build_hita_keys request
    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    equipment_sizes = ""

    request.equipment_sizes.each_with_index do |size, index|
      equipment_sizes += "Medida #{letters[index]}: #{size}, "
    end

    months = {
      'Janeiro' => 'Jan',
      'Fevereiro' => 'Feb',
      'Março' => 'Mar',
      'Abril' => 'Apr',
      'Maio' => 'May',
      'Junho' => 'Jun',
      'Julho' => 'Jul',
      'Agosto' => 'Aug',
      'Setembro' => 'Sep',
      'Outubro' => 'Oct',
      'Novembro' => 'Nov',
      'Dezembro' => 'Dec'
    }.invert

    shipping_modality = request.shipping_modality.blank? ? '' : request.shipping_modality.upcase

    enterprise = request.enterprise
    prec_tot = 0

    produtos = request.request_products.map { |product|
      prec_unit = ((product.calculated_price + product.shipping_price) / product.product_quantity)
      prec_tot_item = prec_unit * product.product_quantity
      prec_tot += prec_tot_item

      {
        cod: product.product.code,
        nome: product.product.name,
        qtd_item: product.product_quantity,
        frete: number_to_currency(product.shipping_price, format: '%n'),
        prec_unit: number_to_currency(prec_unit, format: '%n'),
        prec_tot_item: number_to_currency(prec_tot_item, format: '%n'),
        ipi: "#{product.product.ipi.to_f.round}%",
        caracteristicas: product.product.characteristics,
        rendimento: product.product.income,
        ncm: product.product.ncm.to_f.round
      }
    }

    prec_tot = number_to_currency(prec_tot,  format: '%n')

    service_value = request.value_estimation.nil? ? '' : number_to_currency(request.value_estimation, format: '%n')
    total_shipping = number_to_currency(request.request_products.sum(&:shipping_price).to_f.round(2), format: '%n')

    created_by = request.created_by.nil? ? '' : request.created_by.name
    equipment_name = request.equipment.nil? ? '' : request.equipment.name

    team = request.user.team
    coordinator = User.where(team: team, role: User::ROLES[:regional_coordinator], is_active: true).first
    coordinator = coordinator.nil? ? "" : coordinator.name

    icms = enterprise.state == "BA" ? "18%" : "4%"
    current_user_role = current_user.get_role_name
    current_user_name = current_user.name

    keys = {
      emp_10: enterprise.name,
      tip_11: enterprise.enterprise_type,
      cid_30: enterprise.city,
      est_40: enterprise.state,
      pro_50: request.get_request_code,
      mes_60: months[Date.today.strftime("%b")],
      ano_70: Date.today.strftime("%Y").last(3),
      ano_80: Date.today.strftime("%Y"),
      con_90: request.user.name,
      nom_100: request.collaborator.name,
      tel_110: request.collaborator.friendly_phone,
      ema_120: request.collaborator.email,
      nom_140: request.technician&.name,
      dat_150: Date.today.strftime("%d/%m/%y"),
      dad_160: equipment_sizes,
      mod_fret: shipping_modality,
      produtos: produtos,
      est_valor_serv: service_value,
      fret_tot: total_shipping,
      equip: equipment_name,
      end_client: enterprise.complete_address,
      coord: coordinator,
      cargo: current_user_role,
      nome_do_gerador: current_user_name,
      icms: icms,
      criado_por: created_by,
      prec_tot: prec_tot
    }

    return keys
  end

  def process_quiz_answers request
    processed_keys = {}
    keys = FormKey.all

    keys.each do |key|
      request_quiz_title = key.request_quiz.title

      request.request_quiz_data.each do |quiz|
        parsed_quiz = JSON.parse(quiz.data)

        if parsed_quiz['name'] == request_quiz_title
          user_answers = quiz.get_user_answers_ids
          conditions = key.conditions

          conditions_passed = match_key_conditions(user_answers, conditions)

          processed_keys[key.key_name] =
          if conditions_passed and key.is_answer_printable
            build_user_answer_string(quiz, key.answers_to_print)
          elsif conditions_passed
            key.content
          else
            ""
          end
        end
      end
    end

    return processed_keys
  end

  def build_user_answer_string request_quiz_data, questions_ids
    answer_str = ""

    parsed_data = JSON.parse(request_quiz_data.data)
    parsed_data['questions'].each do |question|
      if "#{question['id']}".in? questions_ids
        answer_str += question['user_answers'].pluck('text').join(', ')
      end
    end

    return answer_str
  end

  def match_key_conditions answers, conditions
    partial_conditions = conditions
    partial_conditions = conditions - answers

    answers.each do |answer|
      partial_conditions -= [answer.to_s.split('.').first]
    end

    return partial_conditions.empty?
  end
end
