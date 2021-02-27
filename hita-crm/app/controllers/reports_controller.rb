class ReportsController < ApplicationController
  def index
    @title  = 'Hita CRM | Relatórios -  Empresas'
    @states = [
      'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
      'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    ].sort

    @sectors = [
      "Alimentos e Bebidas", "Mineração", "Óleo e Gás (Refinaria)", "Óleo e Gás (Offshore)", "Óleo e Gás (Transporte e Tancagem)",
      "Petroquímica", "Siderurgia", "Cimenteira", "Papel e Celulose", "Fertilizantes", "Química", "Naval", "Energia (Hidro)",
      "Energia (Termo)", "Energia (Eólica)", "Energia (Outros)", "Açúcar e alcool", "Saneamento", "Edificios e estruturas",
      "O&M", "Revenda", "Automotiva", "Agrícola", "Têxtil", "Outros", "Consultor", "EPC", "Metalurgia", "Projetos e Engenharia"
    ].sort

    @jobs = [
      "Gerente Geral", "Gerente de Manutenção", "Inspetor", "Membro do PCM", "Membro da Engenharia"
    ]

    @relationships = [
      "Básico/Incipiente", "Intermediário/Simpatizante", "Fiel"
    ]

    @enterprise   = Enterprise.new
    @collaborator = Collaborator.new
    @users        = []

    User.all.each do |user|
      @users << {'key': user.name, 'value': user.name} if user.name
    end

    @enterprise_id = params[:enterprise_id] if params[:enterprise_id].present?

    if current_user.role?(User::ROLES[:regional_coordinator])
      @consultants = User.where(team: current_user.team, is_active: true, role: [0, 5]).order(name: :asc)
    else
      @consultants = User.where(role: [0, 5]).order(name: :asc)
    end

    if current_user.role?(User::ROLES[:consultant])
      @enterprises     = current_user.enterprises
      @enterprise_type = @enterprises.pluck(:enterprise_type).uniq
      @cities          = @enterprises.pluck(:city).uniq.reject(&:blank?)
    elsif current_user.role?(User::ROLES[:regional_coordinator])
      @enterprises     = current_user.get_enterprises_team
      @enterprise_type = @enterprises.pluck(:enterprise_type).uniq
      @cities          = @enterprises.pluck(:city).uniq.reject(&:blank?)
    else
      @enterprises     = Enterprise.all
      @enterprise_type = ['A+', 'A', 'B', 'C']
      @cities          = Enterprise.pluck(:city).uniq.reject(&:blank?)
    end

    @enterprises = @enterprises.order(name: :asc)
    @cities = @cities.sort

    @current_year = Date.today.year

    if params[:filter].present? and params[:filter_value].present?
      @filter       = params[:filter]
      @filter_value = params[:filter_value]
    end
  end

  def index_products
    @title  = 'Hita CRM | Relatórios - Produtos'
    @states = [
      'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
      'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    ].sort

    @sectors = [
      "Alimentos e Bebidas", "Mineração", "Óleo e Gás (Refinaria)", "Óleo e Gás (Offshore)", "Óleo e Gás (Transporte e Tancagem)",
      "Petroquímica", "Siderurgia", "Cimenteira", "Papel e Celulose", "Fertilizantes", "Química", "Naval", "Energia (Hidro)",
      "Energia (Termo)", "Energia (Eólica)", "Energia (Outros)", "Açúcar e alcool", "Saneamento", "Edificios e estruturas",
      "O&M", "Revenda", "Automotiva", "Agrícola", "Têxtil", "Outros", "Consultor", "EPC", "Metalurgia", "Projetos e Engenharia"
    ].sort

    @jobs = [
      "Gerente Geral", "Gerente de Manutenção", "Inspetor", "Membro do PCM", "Membro da Engenharia"
    ]

    @relationships = [
      "Básico/Incipiente", "Intermediário/Simpatizante", "Fiel"
    ]

    if current_user.role?(User::ROLES[:consultant])
      @enterprises     = current_user.enterprises
      @enterprise_type = @enterprises.pluck(:enterprise_type).uniq
      @cities          = @enterprises.pluck(:city).uniq.reject(&:blank?)
    elsif current_user.role?(User::ROLES[:regional_coordinator])
      @enterprises     = current_user.get_enterprises_team
      @enterprise_type = @enterprises.pluck(:enterprise_type).uniq
      @cities          = @enterprises.pluck(:city).uniq.reject(&:blank?)
    else
      @enterprises     = Enterprise.all
      @enterprise_type = Enterprise.pluck(:enterprise_type).uniq
      @cities          = Enterprise.pluck(:city).uniq.reject(&:blank?)
    end

    @enterprises = @enterprises.order(name: :asc)
    @cities = @cities.sort

    @current_year = Date.today.year
    @categories   = Product.pluck(:category).uniq
  end

  def index_services
    @title  = 'Hita CRM | Relatórios - Produtos'
    @states = [
      'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
      'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    ].sort

    @sectors = [
      "Alimentos e Bebidas", "Mineração", "Óleo e Gás (Refinaria)", "Óleo e Gás (Offshore)", "Óleo e Gás (Transporte e Tancagem)",
      "Petroquímica", "Siderurgia", "Cimenteira", "Papel e Celulose", "Fertilizantes", "Química", "Naval", "Energia (Hidro)",
      "Energia (Termo)", "Energia (Eólica)", "Energia (Outros)", "Açúcar e alcool", "Saneamento", "Edificios e estruturas",
      "O&M", "Revenda", "Automotiva", "Agrícola", "Têxtil", "Outros", "Consultor", "EPC", "Metalurgia", "Projetos e Engenharia"
    ].sort

    @jobs = [
      "Gerente Geral", "Gerente de Manutenção", "Inspetor", "Membro do PCM", "Membro da Engenharia"
    ]

    @relationships = [
      "Básico/Incipiente", "Intermediário/Simpatizante", "Fiel"
    ]

    @enterprises     = Enterprise.all.order(name: :asc)
    @enterprise_type = Enterprise.pluck(:enterprise_type).uniq
    @cities          = Enterprise.pluck(:city).uniq.reject(&:blank?)
    @current_year    = Date.today.year
    @categories      = Product.pluck(:category).uniq
    @cities = @cities.sort
  end

  def render_current_enterprises_reports
    @enterprises, @enterprise_filter = search_enterprises params
    @view_mode                       = params[:view_mode] == 'Mês' ? 'Mês' : 'Ano'
    @current_year                    = params[:year]
    @years                           = Report.order(period: :desc).map { |report| report.period.year }.uniq.sort.reverse
    @page                            = params[:page] || 1
    @data_view                       = params[:data_view]

    @months = {
      1 => 'JAN', 2 => 'FEV', 3 => 'MAR', 4 => 'ABR',
      5 => 'MAI', 6 => 'JUN', 7 => 'JUL', 8 => 'AGO',
      9 => 'SET', 10 => 'OUT', 11 => 'NOV', 12 => 'DEZ'
    }

    @visits                   = 0
    @meeting_seminar_training = 0
    @requests                 = 0
    @requests_approved        = 0
    @revenues                 = 0

    enterprises_ids = @enterprises.pluck(:id)

    if @view_mode == 'Ano'
      @meeting_seminar_training =
      Interaction
        .where(enterprise_id: enterprises_ids, interaction_type: ['meeting', 'seminar', 'training'])
        .where('extract(year from created_at) = ?', Date.today.year)
        .size

      @visits =
      Interaction
        .where(enterprise_id: enterprises_ids, interaction_type: 'visit')
        .where('extract(year from created_at) = ?', Date.today.year)
        .size
    else
      @meeting_seminar_training =
      Interaction
        .where(enterprise_id: enterprises_ids, interaction_type: ['meeting', 'seminar', 'training'])
        .where('extract(month from created_at) = ? AND extract(year from created_at) = ?', Date.today.month, Date.today.year)
        .size

      @visits =
      Interaction
        .where(enterprise_id: enterprises_ids, interaction_type: 'visit')
        .where('extract(month from created_at) = ? AND extract(year from created_at) = ?', Date.today.month, Date.today.year)
        .size
    end

    consultant_ids = {}
    consultant_ids[:user_id] = []
    if params[:consultant_ids].present?
      consultant_ids[:user_id] = params[:consultant_ids]
    end

    requests =
    if consultant_ids[:user_id].blank?
      Request.where(enterprise_id: @enterprises.pluck(:id), is_draft: false)
    else
      Request.where(enterprise_id: @enterprises.pluck(:id), is_draft: false, user_id: consultant_ids[:user_id])
    end

    @requests          = requests.size
    @requests_approved = requests.joins(:interactions).where("interactions.interaction_type = 'revenue' OR interactions.interaction_type = 'mobilization'").uniq.size
    @revenues          = requests.joins(:interactions).where("interactions.interaction_type = 'mobilization' OR interactions.interaction_type = 'payment'").uniq.size

    @accomplished_total = {}
    @planned_total = {}

    if @view_mode == 'Ano'
       @years.each do |year|
        @accomplished_total[year] = ReportsHelper.show_enterprise_accomplished_year_total(year, @enterprises.pluck(:id))
        @planned_total[year] = ReportsHelper.show_enterprise_planned_year_total(year, @enterprises.pluck(:id))
      end
    else
      (1..12).each { |month| 
        @accomplished_total[month] = ReportsHelper.show_enterprise_accomplished_month_total(@current_year, month, @enterprises.pluck(:id))
        @planned_total[month] = ReportsHelper.show_enterprise_planned_month_total(@current_year, month, @enterprises.pluck(:id))
      }
    end


    if params[:consultant_ids].present?
      @consultants        = User.where(id: params[:consultant_ids], is_active: true, role: [0, 5]).order(name: :asc)
      accomplished_total  = 0
      planned_total       = 0
      contribution_total  = 0
      @planning_total     = {}
      @enterprise_ids     = @enterprises.pluck(:id)

      if @view_mode == 'Ano'
        @years.each do |year|
          @consultants.each do |consultant|
            accomplished_total += consultant.get_accomplished_enterprise_total_year(year, @enterprise_filter)
            planned_total      += consultant.get_planned_enterprise_total_year(year, @enterprise_filter)
          end

          @planning_total[year] = {
            'accomplished_total' => accomplished_total,
            'planned_total' => planned_total,
            'contribution_total' => accomplished_total.zero? ? 0.0 : 100
          }

          accomplished_total = 0
          planned_total = 0
          contribution_total = 0
        end
      else
        @accomplished_total = {}
        @planned_total = {}

        (1..12).each { |month| 
          month_total_accomplished = 0
          month_total_planned = 0

          @consultants.each do |consultant|
            month_total_accomplished += consultant.get_accomplished_enterprise_total_month(month, @current_year, @enterprise_filter)
            month_total_planned += consultant.get_planned_enterprise_total_month(month, @current_year, @enterprise_filter) if @data_view == 'complete'
          end

          @accomplished_total[month] = month_total_accomplished
          @planned_total[month] = month_total_planned
        }

      end
    end


    @consultants = @consultants.paginate(:page => params[:page], :per_page => 20) if @consultants.present?
    @enterprises = @enterprises.paginate(:page => params[:page], :per_page => 30)
  end

  def render_current_products_reports
    @products, @product_filter, @enterprise_filter = search_product params
    @view_mode                                     = params[:view_mode] == 'Mês' ? 'Mês' : 'Ano'
    @current_year                                  = params[:year]
    @years                                         = Report.order(period: :desc).map { |report| report.period.year }.uniq.sort.reverse
    @product_ids                                   = @products.pluck(:id)
    @page                                          = params[:page] || 1
    @data_view                                     = params[:data_view]


    @months = {
      1 => 'JAN', 2 => 'FEV', 3 => 'MAR', 4 => 'ABR',
      5 => 'MAI', 6 => 'JUN', 7 => 'JUL', 8 => 'AGO',
      9 => 'SET', 10 => 'OUT', 11 => 'NOV', 12 => 'DEZ'
    }

    if params[:category].present?
      @categories = params[:category]
      @products   = @products.group_by(&:category)
    end

    enterprise_ids = Enterprise.where(@enterprise_filter).pluck(:id)

    if params[:request_type].present? and params[:request_type] == 'service'
      @request_type = 'service'
      requests      = Request.where(enterprise_id: enterprise_ids, request_type: 'service', is_active: true)
    else
      @request_type = 'product'
      requests      = Request.where(enterprise_id: enterprise_ids, request_type: 'product', is_active: true)
    end

    @revenues = 0
    @revenues = requests.joins(:interactions).where("interactions.interaction_type = 'revenue'").uniq.size

    @products = @products.paginate(:page => params[:page], :per_page => 30)
  end

  def search_enterprises params
    search_obj = {}

    search_obj[:id]              = params[:enterprise_ids]    if params[:enterprise_ids].present?
    search_obj[:enterprise_type] = params[:enterprise_type]   if params[:enterprise_type].present?
    search_obj[:industry_sector] = params[:enterprise_sector] if params[:enterprise_sector].present?
    search_obj[:state]           = params[:enterprise_state]  if params[:enterprise_state].present?
    search_obj[:city]            = params[:enterprise_city]   if params[:enterprise_city].present?

    if current_user.role?(User::ROLES[:consultant])
      results = current_user.enterprises.where(search_obj)
    elsif current_user.role?(User::ROLES[:regional_coordinator])
      results = current_user.get_enterprises_team.where(search_obj)
    else
      results = Enterprise.where(search_obj)
    end

    return results.order(revenue: :desc), search_obj
  end

  def search_product params
    search_obj         = {}
    search_product_obj = {}

    search_obj[:user_id]         = params[:consultant_ids]    if params[:consultant_ids].present?
    search_obj[:id]              = params[:enterprise_ids]    if params[:enterprise_ids].present?
    search_obj[:enterprise_type] = params[:enterprise_type]   if params[:enterprise_type].present?
    search_obj[:industry_sector] = params[:enterprise_sector] if params[:enterprise_sector].present?
    search_obj[:state]           = params[:enterprise_state]  if params[:enterprise_state].present?
    search_obj[:city]            = params[:enterprise_city]   if params[:enterprise_city].present?

    product_ids = []

    if current_user.role?(User::ROLES[:consultant])
      enterprise_ids = current_user.enterprises.where(search_obj).pluck(:id)
    elsif current_user.role?(User::ROLES[:regional_coordinator])
      enterprise_ids = current_user.get_enterprises_team.pluck(:id)
    else
      enterprise_ids = Enterprise.where(search_obj).pluck(:id)
    end

    requests = Request.where(enterprise_id: enterprise_ids, is_active: true)

    if params[:request_type].present? and params[:request_type] == 'service'
      requests = Request.where(enterprise_id: enterprise_ids, request_type: 'service', is_active: true)

      requests.each do |request|
        product_ids += request.request_products.pluck(:product_id)
      end
    else
      requests = Request.where(enterprise_id: enterprise_ids, request_type: 'product', is_active: true)

      requests.each do |request|
        product_ids += request.request_products.pluck(:product_id)
      end
    end

    search_product_obj[:id]       = product_ids
    search_product_obj[:category] = params[:category] if params[:category].present?

    results = Product.where(search_product_obj)

    return results.order('name ASC'), search_product_obj, search_obj
  end

  def create
    enterprise = Enterprise.find_by_id params[:enterprise_id]

    report_params = {
      enterprise_id: enterprise.id,
      amount: params[:amount],
      year: params[:year],
      report_type: params[:report_type],
      period_type: params[:period_type]
    }

    report_params[:month_number] = params[:month_number] if params[:month_number].present?

    if ReportsHelper.create(report_params)
      head 200
    else
      head 500
    end
  end
end
