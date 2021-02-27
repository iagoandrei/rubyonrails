class UserScoresController < ApplicationController
  def create
    requirement = Requirement.find_by_id params[:requirement_id]
    user        = User.find_by_id params[:user_id]

    raise ActiveRecord::RecordNotFound if requirement.nil? and user.nil?

    month, year = params[:period].split(',')
    year        = year.to_i

    months = {
      'Janeiro' => 'Jan',
      'Fevereiro' => 'Feb',
      'Março' => 'Mar',
      'Abril' => 'Apr',
      'Maio' => 'May',
      'Junho' => 'Jun',
      'Julho' => 'Jul',
      'Agosto' => 'Aug',
      'Setembro' => 'Sep',
      'Outubro' => 'Oct',
      'Novembro' => 'Nov',
      'Dezembro' => 'Dec'
    }

    date = Date.parse "#{months[month]}/#{year}"

    user_score_params = {
      requirement_title: requirement.title,
      current_user_id: user.id,
      comment: params[:comment],
      current_date: date,
      responsible_id: current_user.id
    }

    user_score_params[:user_score_attachment] = params[:user_score_attachment] if params[:user_score_attachment].present?
    user_score_params[:score_type]            = params[:score_type].present? ? params[:score_type] : 'Bônus'
    user_score_params[:score]                 = params[:score] if params[:score].present?

    UserScoresHelper.create user_score_params
    
    flash[:notice] = 'Pontuação cadastrada com sucesso!'

    redirect_to requirements_index_path
  end

  def destroy
    user_score = UserScore.find_by_id params[:id]

    if user_score.destroy
      flash[:notice] = "Pontuação removida com sucesso!"
    else
      flash[:alert] = "Não foi possível remover a pontuação. Tente novamente."
    end

    redirect_to requirements_index_path
  end

  def render_user_scores_month
    @year, @period = params[:filter][:period].split(".")

    if @period == '1'
      @months = (11..16).to_a

      @months.each_with_index do |m, i|
        @months[i] = m - 12 if m > 12
      end
    else
      @months = (5..10).to_a
    end

    @months.each_with_index do |m, i|
      @months[i] = I18n.t("date.abbr_month_names")[@months[i]].upcase
    end

    @users = []

    if params[:filter][:user_ids].present?
      @users = User.where(id: params[:filter][:user_ids], is_active: true)
    else
      if current_user.role?(User::ROLES[:regional_coordinator])
        @users = User.where(team: current_user.team, is_active: true)
      else
        @users = User.where(role: User::ROLES[:consultant], is_active: true)
      end
    end

    @users = @users.sort { |u, l| l.get_user_scores_semester("#{@year}.#{@period}") <=> u.get_user_scores_semester("#{@year}.#{@period}") }
  end
end
