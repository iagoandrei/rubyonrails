class UserScoreCriterionsController < ApplicationController
  def change_state
    UserScoreCriterion.where(criterion_type: params[:criterion_type], year: params[:year], user_id: params[:user_id]).destroy_all

    if UserScoreCriterion.create(criterion_type: params[:criterion_type], year: params[:year], user_id: params[:user_id], status: params[:status])
      res           = {}
      res['status'] = 'done' if params[:status] == 'true'
      res['status'] = 'pendent' if params[:status] == 'false'

      render :json => res, status: 200
    else
      head 500
    end
  end
end
