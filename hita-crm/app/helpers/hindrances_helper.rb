module HindrancesHelper

  def self.create_hindrance(params)
    deterrent = User.find_by id: params[:user_id] if params[:user_id].present?
    detainee = User.find_by id: params[:detainee_id]
    request = Request.find_by id: params[:request_id]
    raise ActiveRecord::RecordNotFound if request.nil? or detainee.nil?

    hindrance = request.hindrances.where(user_id: detainee.id).last

    if hindrance
      return { response: :present, hindrance_id: hindrance.id }
    end

    hindrance = Hindrance.new
    hindrance.deterrent = deterrent
    hindrance.detainee = detainee
    hindrance.request = request
    hindrance.is_active = true

    if hindrance.save
      notification           = Notification.new
      notification.user      = detainee
      notification.request   = request
      notification.hindrance = hindrance
      notification.message   = "#{request.get_request_code}, #{request.enterprise.name}"
      notification.title     = "Você recebeu um impedimento!"
      notification.save

      return { response: :success, hindrance_id: hindrance.id }
    else
      return { response: :error, hindrance_id: nil}
    end
  end
end
