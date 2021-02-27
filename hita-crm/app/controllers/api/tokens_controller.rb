class Api::TokensController < Api::ApiController
  skip_before_action :respond_to_authentication, only: [:user_access_token]

  def user_access_token
    user = User.find_for_authentication(email: login_params[:email])

    if user.valid_password?(login_params[:password])
      return render json: { token: user.authentication_token }, status: :ok
    else
      return render json: { error: true, message: "Forbidden", code: 403 }, status: :forbidden
    end
  end

private
  def login_params
    params.require(:user).permit(:email, :password)
  end
end
