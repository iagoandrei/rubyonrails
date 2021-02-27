class UsersController < ApplicationController
  include Devise::Controllers

  def index
    @users = User.where(is_active: true).order(name: :asc)
    @unable_users = User.where(is_active: false).order(name: :asc)
    authorize! :index, @user

    @roles = [
      ['Consultor', 0], ['Técnico', 1], ['Gerente Técnico', 2],
      ['Admin', 3], ['Comercial', 4], ['Coordenador Regional', 5],
      ['Financeiro', 6], ['Serviço', 7]
    ].sort
  end

  def create
    user           = User.new(create_user_params)
    user.admission = params[:user][:admission] if params[:user][:admission].present?
    user.team      = params[:user][:team] if params[:user][:team].present?

    if user.save
      flash[:notice] = "Usuário cadastrado com sucesso!"
    else
      flash[:alert] = "Erro ao criar usuário! Tente novamente."
    end

    redirect_to index_user_path
  end

  def edit
    @user = User.find_by_id params[:id]

    @roles = [
      ['Consultor', 0], ['Técnico', 1], ['Gerente Técnico', 2],
      ['Admin', 3], ['Comercial', 4], ['Coordenador Regional', 5],
      ['Financeiro', 6], ['Serviço', 7]
    ].sort
  end

  def update
    user = User.find_by_id params[:user][:id]

    if user.update(update_user_params)
      user.update(role: params[:user][:role]) if current_user.role? User::ROLES[:admin]

      user.is_active = (params[:user][:is_active] == 'on') if params[:user][:is_active].present?
      user.save

      flash[:notice] = "Usuário atualizado com sucesso!"
    else
      flash[:alert] = "Erro ao atualizar usuário! Tente novamente."
    end

    redirect_to edit_user_path(user.id)
  end

  def update_password
    user = User.find_by_email params[:user][:email]

    if user.update_attribute(:password, params[:password])
      if user == current_user
        sign_in(user, :bypass => true)
      end

      flash[:notice] = "Senha atualizada com sucesso!"
    else
      flash[:alert] = "Erro ao atualizar senha! Tente novamente."
    end

    redirect_to edit_user_path(user.id)
  end

  def get_user_infos
    user = User.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if user.nil?

    user_json             = user.as_json
    user_json['initials'] = user.get_initials
    user_json['color']    = user.get_color

    render json: user_json
  end

  def users_autocomplete
    search_obj = {}
    search_obj[:is_active] = true

    if params[:role].present?
      if params[:role] == 'technician'
        search_obj[:role] = [User::ROLES[:technician], User::ROLES[:technical_manager]]
      end
    end

    if params[:q].size == 1
      user = User.where(search_obj).where('name ILIKE ?', "#{sanitize_sql_like params[:q]}%").pluck(:name, :id)
    else
      user = User.where(search_obj).where('name ILIKE ?', "%#{sanitize_sql_like params[:q]}%").pluck(:name, :id)
    end

    render json: user.to_json
  end

private
  def update_user_params
    params.require(:user).permit(:email, :name, :phone, :admission, :team, :is_active)
  end

  def create_user_params
    params.require(:user).permit(:email, :name, :password, :role)
  end
end
