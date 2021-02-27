class HindrancesController < ApplicationController
  def index
    @title = 'Hita CRM | Impedimentos'

    drafts_ids = Request.where(is_draft: true).pluck(:id)
    hindrances = current_user.hindrances.where(is_active: true).where.not(request_id: drafts_ids).order(due_time: :asc).group_by(&:is_read)

    @unreaded = hindrances[false]
    @readed = hindrances[true]
  end

  def show_others_hindrances
    @title = 'Hita CRM | Impedimentos'
  end

  def create
    params[:user_id] = current_user.id
    hindrance_response = HindrancesHelper.create_hindrance(params)

    case hindrance_response[:response]
    when :present
      return render json: { created: false, presence: true }, status: :ok
    when :success
      return render json: { created: true, presence: false, user_id: params[:detainee_id] }, status: :ok
    when :error
      return render json: { created: false, presence: false }, status: :internal_server_error
    end
  end

  def change_due_time
    hindrance = Hindrance.find_by id: params[:hindrance_id]
    raise ActiveRecord::RecordNotFound if hindrance.nil?

    date = Date.parse(params[:due_time])
    hindrance.due_time = date
    hindrance.is_read = true

    if hindrance.save
      flash[:notice] = "Prazo atualizado com sucesso!"
    else
      flash[:alert] = "Ocorreu um erro ao atualizar o prazo."
    end

    redirect_to hindrance_index_url
  end

  def change_hindrance
    deterrent = current_user
    detainee = User.find_by id: params[:detainee_id]
    request = Request.find_by id: params[:request_id]
    raise ActiveRecord::RecordNotFound if request.nil? or detainee.nil?

    if request.hindrances.map(&:user_id).include? detainee.id
      hindrance = Hindrance.where(user_id: current_user.id, request_id: request.id).first
      hindrance.destroy
      return render json: { created: false, presence: true }, status: :ok
    end

    hindrance = Hindrance.where(user_id: current_user.id, request_id: request.id).first
    hindrance.detainee = detainee
    hindrance.deterrent = deterrent

    if hindrance.save
      notification           = Notification.new
      notification.user      = detainee
      notification.request   = request
      notification.hindrance = hindrance
      notification.message   = "#{request.get_request_code}, #{request.enterprise.name}"
      notification.title     = "Você recebeu um impedimento!"
      notification.save

      return render json: { created: true, presence: false }, status: :ok
    else
      return render json: { created: false, presence: false }, status: :internal_server_error
    end
  end

  def destroy_request_hindrance
    request = Request.find_by id: params[:request_id]
    return render json: { error: true, message: 'Oportunidade não encontrada.' }, status: :not_found if request.nil?

    detainee = User.find_by id: params[:user_id]
    return render json: { error: true, message: 'Usuário não encontrado.' }, status: :not_found if detainee.nil?

    hindrance = request.hindrances.where(user_id: detainee.id).last
    return render json: { error: true, message: 'Impedimento não encontrado. O mesmo já pode ter sido removido.' }, status: :not_found if hindrance.nil?

    if hindrance.destroy
      return render json: { error: false, message: 'O impedimento foi removido com sucesso.' }, status: :ok
    else
      return render json: { error: true, message: 'Ocorreu um problema ao remover o impedimento.' }, status: :internal_server_error
    end
  end

  def search_hindrances params
    search_obj = {}
    search_obj[:user_id] = params[:user_id] if params[:user_id].present?
    search_obj[:is_active] = true

    drafts_ids = Request.where(is_draft: true).pluck(:id)
    results = Hindrance.where(search_obj).where.not(request_id: drafts_ids)

    return results
  end

  def render_hindrance_table
    @hindrances = search_hindrances params
  end
end
