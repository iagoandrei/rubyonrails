class Api::ApiController < ActionController::API
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  acts_as_token_authentication_handler_for User, fallback: :none
  before_action :respond_to_authentication

  private

  def respond_to_authentication
    return render json: { error: true, message: "Unautorized", code: 403 }, status: :unauthorized if current_user.nil?
  end
end
