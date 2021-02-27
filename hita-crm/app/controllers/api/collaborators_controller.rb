class Api::CollaboratorsController < Api::ApiController

  def create
    enterprise = Enterprise.find_by id: params[:enterprise_id]

    if enterprise
      collaborator = Collaborator.new
      collaborator.name = params[:name]
      collaborator.email = params[:email]
      collaborator.job_role = params[:job_role]
      collaborator.degree_of_relationship = params[:degree_of_relationship]
      collaborator.status = params[:status]
      collaborator.trained = params[:trained]
      collaborator.area = params[:area]
      collaborator.enterprise = enterprise

      if params[:collaborator][:phone].present?
        phone = params[:collaborator][:phone].delete("()").split(" ")
        collaborator.phone_area = phone[0]
        collaborator.phone = phone[1]
      end

      if collaborator.save
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

        return render json: { message: 'Colaborador/Contato salvo com sucesso.', collaborator_id: collaborator.id }, status: :ok
      else
        return render json: { error: true, message: 'Ocorreu um erro ao salvar o Colaborador/Contato' }, status: :internal_server_error
      end
    else
      return render json: { 'msg': 'Empresa não encontrada.' }, status: :not_found
    end
  end

  def enterprise_collaborators
    search_obj = {}
    search_obj[:enterprise_id] = Enterprise.where(user_id: current_user.id).pluck(:id)

    if params[:datetime].present?
      begin
        datetime = DateTime.parse(params[:datetime])
      rescue ArgumentError
        return render json: { error: true, message: 'Ocorreu um erro ao identificar a data.', code: 500 }, status: :internal_server_error
      rescue
        return render json: { error: true, message: 'Ocorreu um erro ao identificar a data.', code: 500 }, status: :internal_server_error
      end

      @collaborators = Collaborator.where(search_obj).where('updated_at >= ?', datetime)
    else
      @collaborators = Collaborator.where(search_obj)
    end
  end

private

  def collaborator_params
    params.require(:collaborator).permit(:name, :email, :job_role, :degree_of_relationship, :status, :trained, :area)
  end
end
