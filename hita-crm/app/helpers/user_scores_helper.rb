module UserScoresHelper
  def self.create(params = {})
    user = User.find_by_id params[:current_user_id]
    return true if user.email == 'priscila.tavares@hita.com.br'

    requirement = Requirement.find_by_title params[:requirement_title]
    user_score  = UserScore.new

    user_score.user                = user
    user_score.requirement         = requirement
    user_score.comment             = params[:comment] if params[:comment].present?
    user_score.score_type          = params[:score_type].present? ? params[:score_type] : 'Bônus'
    user_score.period              = params[:current_date]
    user_score.responsible_id      = params[:responsible_id] if params[:responsible_id].present?
    user_score.request_id          = params[:request_id] if params[:request_id].present?
    user_score.request_proposal_id = params[:request_proposal_id] if params[:request_proposal_id].present?
    user_score.quantity = 1

    if params[:score].present?
      user_score.score    = params[:score].to_f
    else
      user_score.score = user_score.quantity * requirement.weight
      user_score.file.attach params[:user_score_attachment] if params[:user_score_attachment].present?

      month  = user_score.period.month
      year   = user_score.period.year

      if requirement.title == 'Contatos com Clientes'
        scores = user.user_scores
                     .where('extract(month from period) = ? AND extract(year from period) = ?', month, year)
                     .where(requirement_id: requirement.id, score_type: 'Bônus')

        points_in_year = user.get_user_scores_year(requirement.id, Date.today)

        if scores.size > 15 and scores.sum(&:score) < 1 and points_in_year < 10
          user_score.score = user_score.quantity * requirement.weight
        else
          user_score.score = 0
        end
      end
    end

    user_score.save
  end
end
