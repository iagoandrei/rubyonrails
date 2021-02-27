class CollaboratorsController < ApplicationController

  def index
  	@title = 'Hita CRM | Contatos'
    @enterprise = Enterprise.new
    @collaborator = Collaborator.new
    @collaborator_id = params[:collaborator_id] if params[:collaborator_id].present?

    @collaborators = search_collaborators params
    @states = [
      ['Nenhum', ''], 'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
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

    @price_tables = [
      ['Geral FOB' ,'fob_table'], ['Braskem BA, RS, AL', 'braskem_table'], ['Braskem SP', 'braskem_sp_table'],
      ['Vale Fertilizante (Yara)  Tabela/(1-0,0725)', 'yara_table'], ['Mosaic', 'mosaic_table'], ['Vale Mineração', 'vale_mining_table'],
      ['Anglo American', 'anglo_american_table'], ['Arcelor', 'arcelor_table'], ['Modec', 'modec_table'], ['Petrobrás', 'petrobras_table']
    ]

    @relationships = [
      "Básico (relacionamento inicial)", "Intermediário (interações/reunião/visita)", "Avançado (proposta comercial)", "Cliente", "Cliente Fidelizado"
    ].sort

    @areas = [
      "Compras", "Engenharia", "Financeiro", "Geral", "Inspeção", "Manutenção", "Meio Ambiente", "Outros", "Planejamento", "Processo", "Produção", "Segurança"
    ].sort

    @type = ['A+', 'A', 'B', 'C', 'F']

    @users = []

    User.all.each do |user|
      @users << {'key': user.name, 'value': user.name} if user.name
    end

    @consultants_or_commercials = User.where(role: [User::ROLES[:consultant], User::ROLES[:commercial], User::ROLES[:regional_coordinator]], is_active: true).pluck(:name, :id).sort
  end

  def create
    enterprise = Enterprise.find_by id: params[:enterprise_id]

    if enterprise
      @collaborator = Collaborator.new collaborator_params
      @collaborator.enterprise = enterprise

      if params[:collaborator][:phone].present?
        phone = params[:collaborator][:phone].delete("()").split(" ")
        @collaborator.phone_area = phone[0]
        @collaborator.phone = phone[1]
      end

      @collaborator.save

      user_score_params = {
        requirement_title: 'Cadastro de Novos Contatos',
        current_user_id: current_user.id,
        current_date: Date.today
      }

      UserScoresHelper.create user_score_params

      if params[:collaborator][:trained] == 'Sim'
        user_score_params = {
          requirement_title: 'Treinamentos em Salvador',
          current_user_id: current_user.id,
          current_date: Date.today
        }

        UserScoresHelper.create user_score_params
      end

      head 200
    else
      render json: { 'msg': 'Empresa não encontrada. Favor tentar novamente!' }.to_json, status: 404
    end
  end

  def update
    collaborator = Collaborator.find_by id: params[:collaborator][:id]
    raise ActiveRecord::RecordNotFound if collaborator.nil?

    phone = params[:collaborator][:phone].delete("()").split(" ")
    collaborator.phone_area = phone[0]
    collaborator.phone = phone[1]

    enterprise = Enterprise.find_by id: params[:collaborator][:enterprise_id]
    raise ActiveRecord::RecordNotFound if enterprise.nil?

    old_enterprise =
    if params[:collaborator][:enterprise_id].to_i != collaborator.enterprise_id
      collaborator.enterprise_id
    else
      0
    end

    collaborator.enterprise = enterprise
    collaborator.name = params[:collaborator][:name]
    collaborator.email = params[:collaborator][:email]
    collaborator.job_role = params[:collaborator][:job_role]
    collaborator.degree_of_relationship = params[:collaborator][:degree_of_relationship]
    collaborator.status = params[:collaborator][:status]
    collaborator.trained = params[:collaborator][:trained]
    collaborator.area = params[:collaborator][:area]

    if collaborator.save
      if old_enterprise > 0
        interaction_params = {
          collaborator_id: params[:collaborator][:id],
          owner_id: current_user.id,
          old_enteprise_id: old_enterprise,
          new_enteprise_id: collaborator.enterprise_id
        }

        InteractionHelper.create 'collaborator_enterprise_changed', interaction_params
      end

      flash[:notice] = "Contato atualizado com sucesso"

      redirect_to collaborators_index_url
    else
      head 500
    end
  end

  def destroy
    collaborator = Collaborator.find_by id: params[:collaborator][:id]
    raise ActiveRecord::RecordNotFound if collaborator.nil?

    if collaborator.destroy
      flash[:notice] = "Contato removido com sucesso!"
    else
      flash[:alert] = "Ocorreu um erro inesperado! Tente novamente."
    end

    redirect_to collaborators_index_path
  end

  def render_current_collaborators
    @collaborators = search_collaborators params
  end

  def search_collaborators params
    search_obj                          = {}
    search_obj[:degree_of_relationship] = params[:degree_of_relationship] if params[:degree_of_relationship].present?
    search_obj[:job_role]               = params[:job_role]               if params[:job_role].present?
    search_obj[:area]                   = params[:area]                   if params[:area].present?

    if current_user.role?(User::ROLES[:regional_coordinator])
      search_obj[:enterprise_id] = current_user.get_enterprises_team.pluck(:id)
    elsif current_user.role?(User::ROLES[:consultant])
      search_obj[:enterprise_id] = current_user.enterprises.pluck(:id)
    else
      unless can? :read, Enterprise, :user_id
        search_obj[:enterprise_id] = current_user.enterprises.pluck(:id)
      end
    end

    results = Collaborator.where(search_obj).paginate(:page => params[:page], :per_page => 20)
    results = results.where('name ILIKE ?', "%#{params[:name]}%")
    return results.order('name ASC')
  end

  def get_collaborator_infos
    collaborator = Collaborator.find_by id: params[:id]
    collaborator_json = collaborator.as_json
    collaborator_json['enterprise_name'] = collaborator.enterprise&.name
    collaborator_json['enterprise_id'] = collaborator.enterprise&.id
    collaborator_json['status'] = collaborator.status
    collaborator_json['status_name'] = collaborator.get_status_name

    collaborator_json['interactions'] = collaborator.interactions.map do |interaction|
      {
        "content": interaction.print_interaction
      }
    end

    raise ActiveRecord::RecordNotFound if collaborator.nil?
    render json: collaborator_json
  end

  def get_interactions
    collaborator = Collaborator.find_by id: params[:id]

    raise ActiveRecord::RecordNotFound if collaborator.nil?

    collaborator_json                 = {}
    collaborator_json['interactions'] = collaborator.interactions.map do |interaction|
      {
        "content": interaction.print_interaction
      }
    end

    render json: collaborator_json
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
      current: 'collaborator',
      content: params[:content],
      collaborator_id: params[:collaborator][:id],
      owner_id: current_user.id,
      mentioned_users_id: mentioned_users_id
    }

    interaction_params[:interaction_attachment] = params[:interaction_attachment] if params[:interaction_attachment]

    InteractionHelper.create params[:interaction_type], interaction_params

    head 200
  end

  def check_existence
    collaborator = Collaborator.where(name: params[:name], email: params[:email]).last
    render json: collaborator.as_json
  end

  def get_collaborators_by_enterprise
    collaborators = Collaborator.where(enterprise_id: params[:enterprise_id], status: Collaborator::STATUS[:active]).pluck(:id, :name)
    render json: collaborators.as_json
  end

private
  def collaborator_params
    params.require(:collaborator).permit(:name, :email, :job_role, :degree_of_relationship, :status, :trained, :area)
  end
end
