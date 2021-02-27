class RequirementsController < ApplicationController
  def index
    if current_user.role?(User::ROLES[:technical_manager]) or current_user.role?(User::ROLES[:admin]) or
      current_user.role?(User::ROLES[:commercial]) or current_user.role?(User::ROLES[:regional_coordinator])

      return redirect_to index_technical_manager_path
    end

    if ["Nov", "Dec", "Jan", "Feb", "Mar", "Apr"].include? Date.today.strftime('%b')
      if ['Nov', 'Dec'].include? Date.today.strftime('%b')
        @period = "#{Date.today.year + 1}.1"
      else
        @period = "#{Date.today.year}.1"
      end
    else
      @period = "#{Date.today.year}.2"
    end

    if [11, 12].include? Date.today.month
      start_month = Date.new.change(:month => 11, :year => Date.today.year)
      end_month   = Date.new.change(:month => 10, :year => Date.today.year + 1)
    else
      start_month = Date.new.change(:month => 11, :year => Date.today.year - 1)
      end_month   = Date.new.change(:month => 10, :year => Date.today.year)
    end

    @total_user_score = current_user.user_scores.where(period: start_month..end_month.end_of_month, score_type: 'Bônus').sum(&:score)
    @total_user_score -= current_user.user_scores.where(period: start_month..end_month.end_of_month, score_type: 'Penalidade').sum(&:score)

    user_score_bonus = current_user.user_scores.where(period: start_month..end_month.end_of_month, score_type: 'Bônus').group("DATE_TRUNC('month', period)").sum(:score)
    user_score_penalties = current_user.user_scores.where(period: start_month..end_month.end_of_month, score_type: 'Penalidade').group("DATE_TRUNC('month', period)").sum(:score)

    user_score_bonus.each do |period, score|
      user_score_bonus[period] = user_score_bonus[period] - user_score_penalties[period] if user_score_penalties[period].present?
    end

    @best_month = user_score_bonus.max_by { |k, v| v }
    @current_year, @current_semester = @period.split('.')
    @current_ranking = current_user.get_current_ranking
  end

  def index_technical_manager
    if ["Nov", "Dec", "Jan", "Feb", "Mar", "Apr"].include? Date.today.strftime('%b')
      if ['Nov', 'Dec'].include? Date.today.strftime('%b')
        @period = "#{Date.today.year + 1}.1"
      else
        @period = "#{Date.today.year}.1"
      end
    else
      @period = "#{Date.today.year}.2"
    end

    @current_year, @current_semester = @period.split('.')
  end

  def render_months
    @requirements  = Requirement.order(id: :asc)
    @year, @period = params[:period].split(".")

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

    semester_months = {
      "1" => ["Nov", "Dec", "Jan", "Feb", "Mar", "Apr"],
      "2" => ["May", "Jun", "Jul", "Aug", "Sep", "Oct"]
    }

    @scores = []

    semester_months[@period].each do |month|
      @scores <<
      if (@period == '1') and (['Nov', 'Dec'].include? month)
        score = current_user.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', @year.to_i - 1, Date.parse("#{month}/#{@year.to_i - 1}").month)
        .where(score_type: 'Bônus').sum(&:score)

        score -= current_user.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', @year.to_i - 1, Date.parse("#{month}/#{@year.to_i - 1}").month)
        .where(score_type: 'Penalidade').sum(&:score)
      else
        score = current_user.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', @year, Date.parse("#{month}/#{@year}").month)
        .where(score_type: 'Bônus').sum(&:score)

        score -= current_user.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', @year, Date.parse("#{month}/#{@year}").month)
        .where(score_type: 'Penalidade').sum(&:score)
      end
    end

    @criterion = {}

    if [11, 12].include? Date.today.month
      year = Date.today.year + 1

      count_months = get_months_count(Date.new.change(:month => 10, :year => year), current_user.admission)
    else
      year = Date.today.year

      count_months = get_months_count(Date.new.change(:month => 10, :year => year), current_user.admission)
    end

    if count_months <= 24
      @criterion['sale'] = {
        "title" => "Vender ao menos R$ 250.000,00 em #{year}",
        "amount" => 250.0
      }
    elsif count_months > 25 and count_months <= 48
      @criterion['sale'] = {
        "title" => "Vender ao menos R$ 450.000,00 em #{year}",
        "amount" => 450.0
      }
    elsif count_months > 48
      @criterion['sale'] = {
        "title" => "Vender ao menos R$ 650.000,00 em #{year}",
        "amount" => 650.0
      }
    end

    if count_months <= 12
      @criterion['boi'] = "Concluir BOI Básico"
    elsif count_months > 12 and count_months <= 24
      @criterion['boi'] = "Concluir BOI Intermediário"
    elsif count_months > 24
      @criterion['boi'] = "Concluir BOI Avançado"
    end

    @criterion['planning'] = "Apresentar planejamento até final de #{year - 1}"
    @criterion['bel'] = "Responder ao menos 70% das provas da BEL em #{year}"
  end

  def get_requirement_infos
    requirement = Requirement.find_by id: params[:id]

    raise ActiveRecord::RecordNotFound if requirement.nil?

    requirement_json           = requirement.as_json
    requirement_json['months'] = []

    current_month = Date.current.month
    current_year  = Date.current.year

    requirement_json['current_period'] = I18n.l(Date.new.change(:month => current_month, :year => current_year), format: :month_year_2)

    if [11, 12].include? Date.today.month
      months = [
        I18n.l(Date.new.change(:month => 11, :year => Date.today.year), format: :month_year_2),
        I18n.l(Date.new.change(:month => 12, :year => Date.today.year), format: :month_year_2)
      ]
    else
      months = [
        I18n.l(Date.new.change(:month => 11, :year => Date.today.year - 1), format: :month_year_2),
        I18n.l(Date.new.change(:month => 12, :year => Date.today.year - 1), format: :month_year_2)
      ]

      (1..10).to_a.each do |e|
        months << I18n.l(Date.new.change(:month => e, :year => Date.today.year), format: :month_year_2)
      end
    end

    requirement_json['months'] = months

    requirement_json['scores'] = {}
    requirement_json['scores'] = []

    if [11, 12].include? Date.today.month
      start_month = Date.new.change(:month => 11, :year => Date.today.year)
      end_month   = Date.new.change(:month => 10, :year => Date.today.year + 1)
    else
      start_month = Date.new.change(:month => 11, :year => Date.today.year - 1)
      end_month   = Date.new.change(:month => 10, :year => Date.today.year)
    end

    user_scores = requirement.user_scores.where(period: start_month..end_month.end_of_month, user_id: params[:user_id]).order(created_at: :desc)

    user_scores.each do |score|
      score_params                = {}
      score_params['comment']     = score.comment if score.comment
      score_params['period']      = I18n.l(score.period, format: :month_year_2)
      score_params['score_type']  = score.score_type
      score_params['score']       = score.score.to_f
      score_params['responsible'] = score.responsible.name if score.responsible

      if score.file.attached?
        score_params.merge!({
          name: score.file.filename, size: score.file.byte_size, uploaded_at: score.created_at.strftime("%d/%m/%Y"), id: score.id,
          link: Rails.application.routes.url_helpers.rails_blob_path(score.file, only_path: true, disposition: 'attachment'),
          link_destroy: user_scores_destroy_path(score.id)
        })
      end

      requirement_json['scores'] << score_params
    end

    render json: requirement_json
  end

  def render_individual_user_scores_month
    @requirements  = Requirement.order(id: :asc)
    @year, @period = params[:filter][:period].split(".")
    @user          = User.find_by_id params[:filter][:user_ids]

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

    semester_months = {
      "1" => ["Nov", "Dec", "Jan", "Feb", "Mar", "Apr"],
      "2" => ["May", "Jun", "Jul", "Aug", "Sep", "Oct"]
    }

    @scores = []

    semester_months[@period].each do |month|
      if (@period == '1') and (['Nov', 'Dec'].include? month)
        score = @user.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', @year.to_i - 1, Date.parse("#{month}/#{@year.to_i - 1}").month)
        .where(score_type: 'Bônus').sum(&:score)

        score -= @user.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', @year.to_i - 1, Date.parse("#{month}/#{@year.to_i - 1}").month)
        .where(score_type: 'Penalidade').sum(&:score)

        @scores << score
      else
        score = @user.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', @year, Date.parse("#{month}/#{@year}").month)
        .where(score_type: 'Bônus').sum(&:score)
        score -= @user.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', @year, Date.parse("#{month}/#{@year}").month)
        .where(score_type: 'Penalidade').sum(&:score)

        @scores << score
      end
    end

    start_month = Date.new.change(month: 11, year: @year.to_i - 1)
    end_month   = Date.new.change(month: 10, year: @year.to_i)

    @user_scores_semester = @user.user_scores.where(period: start_month..end_month.end_of_month).where(score_type: 'Bônus').sum(&:score)
    @user_scores_semester -= @user.user_scores.where(period: start_month..end_month.end_of_month).where(score_type: 'Penalidade').sum(&:score)

    @criterion = {}

    if [11, 12].include? Date.today.month
      year = Date.today.year + 1

      count_months = get_months_count(Date.new.change(:month => 10, :year => year), @user.admission)
    else
      year = Date.today.year

      count_months = get_months_count(Date.new.change(:month => 10, :year => year), @user.admission)
    end

    if count_months <= 24
      @criterion['sale'] = {
        "title" => "Vender ao menos R$ 250.000,00 em #{year}",
        "amount" => 250.0
      }
    elsif count_months > 25 and count_months <= 48
      @criterion['sale'] = {
        "title" => "Vender ao menos R$ 450.000,00 em #{year}",
        "amount" => 450.0
      }
    elsif count_months > 48
      @criterion['sale'] = {
        "title" => "Vender ao menos R$ 650.000,00 em #{year}",
        "amount" => 650.0
      }
    end

    if count_months <= 12
      @criterion['boi'] = "Concluir BOI Básico"
    elsif count_months > 12 and count_months <= 24
      @criterion['boi'] = "Concluir BOI Intermediário"
    elsif count_months > 24
      @criterion['boi'] = "Concluir BOI Avançado"
    end

    @criterion['planning'] = "Apresentar planejamento até final de #{year}"
    @criterion['bel'] = "Responder ao menos 70% das provas da BEL em #{year}"
  end

private

  def get_months_count(date_1, date_2)
    if date_1 and date_2
      return ((date_1.to_date.year * 12 + date_1.to_date.month) - (date_2.to_date.year * 12 + date_2.to_date.month)).abs
    else
      return 0
    end
  end
end
