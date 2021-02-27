class ApplicationController < ActionController::Base
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  layout :layout_by_resource
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do | exception |
    redirect_to root_url, alert: exception.message
  end

private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def layout_by_resource
    if devise_controller?
      "login"
    else
      "application"
    end
  end
end
