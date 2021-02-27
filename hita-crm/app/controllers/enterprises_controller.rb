class EnterprisesController < ApplicationController
  skip_before_action :verify_authenticity_token #check this

  include InteractionHelper
  def map
    @key = 'AIzaSyDJOpGmB0SRs9hmrNdFyKGy3E9OlIfOgHs'
    @latitude = '-12.974722'
    @longitude = '-38.476665'	
    @title = 'Hita CRM | Mapa'
    @states = [
      ['--', ''], 'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
      'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    ]

    @sectors = [
      "Agrícola", "Alimentos e Bebidas", "Automotiva", "Açúcar e alcool", "Cimenteira",
      "Edifícios e Estruturas", "Energia (Éolica)", "Energia (Hidro)", "Energia (Outros)",
      "Energia (Termo)", "Fertilizantes", "Mineração", "Naval", "O&M", "Papel e Celulose",
      "Petroquímica", "Química", "Revenda", "Saneamento", "Siderurgia", "Têxtil", "Óleo e Gás (Offshore)",
      "Óleo e Gás (Refinaria)", "Óleo e Gás (Transporte e Tancagem)", "Outros", "Consultor", "EPC", "Metalurgia", "Projetos e Engenharia"
    ].sort

    @jobs = [
      "Assistente", "Analista", "Coordenador", "Diretor", "Gerente", "Inspetor", "Membro", "Operador", "Outros", "Programador", "Supervisor"
    ].sort

    @relationships = [
      "Básico (relacionamento inicial)", "Intermediário (interações/reunião/visita)", "Avançado (proposta comercial)", "Cliente", "Cliente Fidelizado"
    ].sort

    @price_tables = [
      ['Geral FOB' ,'fob_table'], ['Braskem BA, RS, AL', 'braskem_table'], ['Braskem SP', 'braskem_sp_table'],
      ['Vale Fertilizante (Yara)  Tabela/(1-0,0725)', 'yara_table'], ['Mosaic', 'mosaic_table'], ['Vale Mineração', 'vale_mining_table'],
      ['Anglo American', 'anglo_american_table'], ['Arcelor', 'arcelor_table'], ['Modec', 'modec_table'], ['Petrobrás', 'petrobras_table']
    ]

    @areas = [
      "Compras", "Engenharia", "Financeiro", "Geral", "Inspeção", "Manutenção", "Meio Ambiente", "Outros", "Planejamento", "Processo", "Produção", "Segurança"
    ].sort

    @type = ['A+', 'A', 'B', 'C', 'F']

    @enterprise = Enterprise.new
    @collaborator = Collaborator.new

    @consultants_or_commercials = User.where(role: [User::ROLES[:consultant], User::ROLES[:commercial], User::ROLES[:regional_coordinator]], is_active: true).pluck(:name, :id).sort

    @users = []

    User.all.each do |user|
      @users << {'key': user.name, 'value': user.name} if user.name
    end

    @enterprise_id = params[:enterprise_id] if params[:enterprise_id].present?

    @show_new_enterprise = true if params[:new_enterprise]  


  end
  def mapfilter
      enterprise= search_enterprises params
      render json: enterprise.as_json     
  end  
  def index
  	@title = 'Hita CRM | Empresas'
    @states = [
      ['--', ''], 'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
      'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    ]

    @sectors = [
      "Agrícola", "Alimentos e Bebidas", "Automotiva", "Açúcar e alcool", "Cimenteira",
      "Edifícios e Estruturas", "Energia (Éolica)", "Energia (Hidro)", "Energia (Outros)",
      "Energia (Termo)", "Fertilizantes", "Mineração", "Naval", "O&M", "Papel e Celulose",
      "Petroquímica", "Química", "Revenda", "Saneamento", "Siderurgia", "Têxtil", "Óleo e Gás (Offshore)",
      "Óleo e Gás (Refinaria)", "Óleo e Gás (Transporte e Tancagem)", "Outros", "Consultor", "EPC", "Metalurgia", "Projetos e Engenharia"
    ].sort

    @jobs = [
      "Assistente", "Analista", "Coordenador", "Diretor", "Gerente", "Inspetor", "Membro", "Operador", "Outros", "Programador", "Supervisor", "Engenheiro"
    ].sort

    @relationships = [
      "Básico (relacionamento inicial)", "Intermediário (interações/reunião/visita)", "Avançado (proposta comercial)", "Cliente", "Cliente Fidelizado"
    ].sort

    @price_tables = [
      ['Geral FOB' ,'fob_table'], ['Braskem BA, RS, AL', 'braskem_table'], ['Braskem SP', 'braskem_sp_table'],
      ['Vale Fertilizante (Yara)  Tabela/(1-0,0725)', 'yara_table'], ['Mosaic', 'mosaic_table'], ['Vale Mineração', 'vale_mining_table'],
      ['Anglo American', 'anglo_american_table'], ['Arcelor', 'arcelor_table'], ['Modec', 'modec_table'], ['Petrobrás', 'petrobras_table']
    ]

    @areas = [
      "Compras", "Engenharia", "Financeiro", "Geral", "Inspeção", "Manutenção", "Meio Ambiente", "Outros", "Planejamento", "Processo", "Produção", "Segurança"
    ].sort

    @type = ['A+', 'A', 'B', 'C', 'F']

    @enterprise = Enterprise.new
    @collaborator = Collaborator.new

    @consultants_or_commercials = User.where(role: [User::ROLES[:consultant], User::ROLES[:commercial], User::ROLES[:regional_coordinator]], is_active: true).pluck(:name, :id).sort

    @users = []

    User.all.each do |user|
      @users << {'key': user.name, 'value': user.name} if user.name
    end

    @enterprise_id = params[:enterprise_id] if params[:enterprise_id].present?

    @show_new_enterprise = true if params[:new_enterprise]
  end

  def create
    @enterprise      = Enterprise.new enterprise_params
    @enterprise.name = @enterprise.name.upcase

    if params[:enterprise][:consultant_id]
      user             = User.find_by_id params[:enterprise][:consultant_id]
      @enterprise.user = user
    else
      @enterprise.user = current_user
    end

    @enterprise.save

    redirect_to enterprises_index_url
  end

  def check_existence
    enterprise = Enterprise.where(name: params[:name].upcase, cnpj: params[:cnpj]).last
    render json: enterprise.as_json
  end

  def update
    enterprise = Enterprise.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if enterprise.nil?

    if params[:enterprise][:consultant_id].present?
      user            = User.find_by_id params[:enterprise][:consultant_id]
      enterprise.user = user

      enterprise.save
    end

    if enterprise.update(enterprise_params)
      enterprise.update_attribute(:name, enterprise.name.upcase)
      redirect_to enterprises_index_url
    else
      head 500
    end
  end

  def render_current_enterprises
    @enterprises = search_enterprises params
  end

  def search_enterprises params
    search_obj = {}
    search_obj[:enterprise_type] = params[:enterprise_type] if params[:enterprise_type].present?
    search_obj[:industry_sector] = params[:industry_sector] if params[:industry_sector].present?
    search_obj[:state] = params[:state] if params[:state].present?


    if params[:order] == 'Faturamento'
      results = Enterprise.where(search_obj).order(revenue: :desc).paginate(:page => params[:page], :per_page => 30)
    elsif params[:map]
      results = Enterprise.where(search_obj).order(revenue: :desc).paginate(:page => params[:page], :per_page => 200)
    else
      results = Enterprise.where(search_obj).order(name: :asc).paginate(:page => params[:page], :per_page => 30)
    end

    if params[:start_date].present? and params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date   = Date.parse(params[:end_date])

      results = Enterprise.where(search_obj).where(created_at: start_date.beginning_of_day..end_date.end_of_day).paginate(:page => params[:page], :per_page => 30)
    end

    if current_user.role?(User::ROLES[:regional_coordinator])
      user_ids = User.where(team: current_user.team, is_active: true).pluck(:id)
      results  = results.where(user_id: user_ids)
    elsif current_user.role?(User::ROLES[:consultant])
      results = results.where(user_id: current_user.id)
    else
      unless can? :read, Enterprise, :user_id
        results = results.where(user_id: current_user.id)
      end
    end

    results = results.where('enterprises.name ILIKE ?', "%#{params[:name]}%") if params[:name].present?
    results = results.where('city ILIKE ?', "%#{params[:city]}%") if params[:city].present?
    
    results = results.joins(:user).where('users.name ILIKE ?', "%#{params[:consultant_name]}%") if params[:consultant_name].present?
    
    if params[:time_period].present?
      to_date = DateTime.current.end_of_day

      case params[:time_period]
      when 'last_week'
        from_date = DateTime.current.beginning_of_day - 1.week
      when 'this_month'
        from_date = DateTime.current.beginning_of_month.beginning_of_day
      when 'last_3_months'
        from_date = DateTime.current.beginning_of_month.beginning_of_day - 3.months
      end

      results = results.where(created_at: from_date..to_date)
    end

    return results
  end

  def enterprises_autocomplete
    search_obj = {}

    if current_user.role?(User::ROLES[:regional_coordinator])
      search_obj[:id] = current_user.get_enterprises_team.pluck(:id)
    elsif current_user.role?(User::ROLES[:consultant])
      search_obj[:id] = current_user.enterprises.pluck(:id)
    else
      unless can? :read, Enterprise, :user_id
        search_obj[:id] = current_user.enterprises.pluck(:id)
      end
    end

    if params[:q].size == 1
      enterprises = Enterprise.where(search_obj).where('name ILIKE ?', "#{sanitize_sql_like params[:q]}%").pluck(:name, :id)
    else
      enterprises = Enterprise.where(search_obj).where('name ILIKE ?', "%#{sanitize_sql_like params[:q]}%").pluck(:name, :id)
    end

    render json: enterprises.to_json
  end

  def get_enterprise_infos
    enterprise = Enterprise.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if enterprise.nil?

    enterprise_json                    = enterprise.as_json
    enterprise_json['collaborators']   = enterprise.collaborator.map do |collaborator|
      {
        "id": collaborator.id,
        "initials": collaborator.get_initials,
        "color": collaborator.get_color,
        "name": collaborator.name
      }.as_json
    end

    enterprise_json['requests'] = enterprise.requests.where(is_draft: false).size
    enterprise_json['revenue']  = ActionController::Base.helpers.number_to_currency(enterprise.revenue)

    if enterprise.user
      enterprise_json['consultant']                  = {}
      enterprise_json['consultant']['name']          = enterprise.user.name
      enterprise_json['consultant']['initials_name'] = enterprise.user.get_initials
      enterprise_json['consultant']['color']         = enterprise.user.get_color
      enterprise_json['consultant']['id']            = enterprise.user.id
    end

    enterprise_json['interactions'] = enterprise.interactions.order(created_at: :asc).map do |interaction|
      {
        "content": interaction.print_interaction
      }
    end

    enterprise_json['complete_address'] = enterprise.complete_address

    render json: enterprise_json
  end

  def get_interactions
    enterprise = Enterprise.find_by id: params[:id]

    raise ActiveRecord::RecordNotFound if enterprise.nil?

    enterprise_json                 = {}
    enterprise_json['interactions'] = enterprise.interactions.order(created_at: :asc).map do |interaction|
      {
        "content": interaction.print_interaction
      }
    end

    render json: enterprise_json
  end

  def create_interaction
    mentioned_users_id = []

    if params[:mentions].present?
      JSON.parse(params[:mentions]).each do |name|
        user = User.find_by_name name

        if user and user.name and params[:content].include? "@#{user.name}"
          params[:content] = params[:content].gsub("@#{user.name}", "<span class='blue-light-color'>@#{user.name}</span>")
          mentioned_users_id << user.id
        end
      end
    end

    interaction_params = {
      current: 'enterprise',
      content: params[:content],
      enterprise_id: params[:enterprise][:id],
      owner_id: current_user.id,
      mentioned_users_id: mentioned_users_id,
      interaction_date: params[:interaction_date]
    }

    if params[:collaborator] and params[:collaborator][:id].present?
      interaction_params[:collaborator_id] = params[:collaborator][:id]
    end

    interaction_params[:interaction_attachment] = params[:interaction_attachment] if params[:interaction_attachment]

    InteractionHelper.create params[:interaction_type], interaction_params

    if params[:interaction_type] == 'visit' or params[:interaction_type] == 'seminar' or params[:interaction_type] == 'meeting' or params[:interaction_type] == 'training'

      if params[:interaction_type] == 'seminar'
        user_score_params = {
          requirement_title: 'Seminários ou Treinamentos',
          current_user_id: current_user.id,
          current_date: Date.today
        }

        UserScoresHelper.create user_score_params
      end

      user_score_params = {
        requirement_title: 'Contatos com Clientes',
        current_user_id: current_user.id,
        current_date: Date.today
      }

      UserScoresHelper.create user_score_params
    end

    head 200
  end

  def upload_chart
    enterprise = Enterprise.find_by_id params[:enterprise_id]

    if params[:chart_type] == 'flow'
      if enterprise.flow_charts.attach params[:file]

        user_score_params = {
          requirement_title: 'Fluxograma',
          current_user_id: current_user.id,
          user_score_attachment: params[:file],
          current_date: Date.today
        }

        UserScoresHelper.create user_score_params

        return head :ok
      end
    else
      if enterprise.organization_charts.attach params[:file]
        user_score_params = {
          requirement_title: 'Organograma',
          current_user_id: current_user.id,
          user_score_attachment: params[:file],
          current_date: Date.today
        }

        UserScoresHelper.create user_score_params

        return head :ok
      end
    end

    head :internal_server_error
  end

  def upload_file
    enterprise = Enterprise.find_by id: params[:enterprise_id]
    raise ActiveRecord::RecordNotFound if enterprise.nil?

    if enterprise.files.attach(params[:files]) and enterprise.save
      head 200
    else
      head 500
    end
  end

  def render_enterprise_files
    enterprise = Enterprise.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if enterprise.nil?

    @enterprise_name = enterprise.name

    files_json = []
    enterprise.files.blobs.each do |blob|
      current_blob = {}
      current_blob['filename'] = blob.filename
      current_blob['date'] = blob.created_at.strftime("%d/%m/%y %H:%M")
      current_blob['size'] = number_to_human_size(blob.byte_size)
      current_blob['blob_path'] = rails_blob_path(blob, disposition: "attachment")
      current_blob['blob_id'] = blob.id
      files_json << current_blob
    end

    return @files = files_json
  end

  def get_enterprise_charts
    enterprise = Enterprise.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if enterprise.nil?

    files = []
    data = {}
    data['enterprise_name'] = enterprise.name

    blobs =
    if params[:chart_type] == 'flow'
      enterprise.flow_charts.blobs
    else
      enterprise.organization_charts.blobs
    end

    blobs.each do |blob|
      current_blob = {}
      current_blob['filename'] = blob.filename
      current_blob['date'] = blob.created_at.strftime("%d/%m/%y %H:%M")
      current_blob['size'] = number_to_human_size(blob.byte_size)
      current_blob['blob_path'] = rails_blob_path(blob, disposition: "attachment")
      current_blob['blob_id'] = blob.id
      files << current_blob
    end

    data['files'] = files
    render json: data.as_json
  end

  def remove_file
    blob = ActiveStorage::Attachment.find_by_id params[:id]
    blob.purge
  end

  def destroy
    enterprise = Enterprise.find_by_id params[:id]
    requests   = enterprise.requests

    if requests.size > 0
      flash[:alert] = "A empresa possui pedidos ou rascunhos alocados. Não é possível remover!"
    else
      if enterprise.destroy
        flash[:notice] = "Empresa removida com sucesso"
      else
        flash[:alert] = "Não foi possível remover a empresa. Favor tentar novamente"
      end
    end

    redirect_to enterprises_index_path
  end

  def get_enterprise_requests
    enterprise = Enterprise.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if enterprise.nil?

    requests = enterprise.requests
    requests_json = []

    requests.where(is_draft: false, is_active: true).each do |request|
      current_request = {}
      current_request['id'] = request.id
      current_request['visual_id'] = 'Pedido #' + request.get_request_code
      requests_json << current_request
    end

    render json: requests_json.as_json
  end

private
  def enterprise_params
    params.require(:enterprise).permit(:name, :industry_sector, :enterprise_type, :cnpj, :price_table,
                                       :cep, :city, :state, :address, :business_name)
  end
end
