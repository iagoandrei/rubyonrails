class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  acts_as_token_authenticatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :enterprises
  has_many :interactions
  has_many :notifications
  has_many :requests
  has_many :detainees, class_name: 'Hindrance', foreign_key: 'created_by'
  has_many :hindrances
  has_one  :request_quiz
  has_many :user_scores
  has_many :reports
  has_and_belongs_to_many :events
  has_many :responsible_scores, class_name: 'UserScore', foreign_key: 'responsible_id'
  has_many :score_criterions, class_name: 'UserScoreCriterion', dependent: :destroy

  validates :email,
    :uniqueness => {
    :message => I18n.t('form.error.email_exists')
  },
    :length => {
    :within => 5..60,
    :message => I18n.t('form.error.email_short')
  },
    :format => {
    :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$/i,
    :multiline => true,
    :message => I18n.t('form.error.invalid_format')
  }

  validates :name, presence: true,
            length: { minimum: 4 }

  ROLES = {
    :consultant => 0, :technician => 1, :technical_manager => 2, :admin => 3,
    :commercial => 4, :regional_coordinator => 5, :financial => 6, :service => 7
  }

  def active_for_authentication?
    super and self.is_active
  end

  def role?(role_name)
    self.role == role_name
  end

  def get_role_name
    return "Consultor"            if self.role == 0
    return "Técnico"              if self.role == 1
    return "Gerente Técnico"      if self.role == 2
    return "Admin"                if self.role == 3
    return "Comercial"            if self.role == 4
    return "Coordenador Regional" if self.role == 5
    return "Financeiro"           if self.role == 6
    return "Serviço"              if self.role == 7
    return ""
  end

  def get_initials
    splited_name = self.name.split(' ')
    return splited_name.reduce { |arr, str| arr.first.upcase + str.first.upcase } if splited_name.size > 1
    return splited_name[0][0] + splited_name[0][1]
  end

  def hsl_user_color hex
    r = ((hex[1] + hex[2]).to_i(16))/255.0
    g = ((hex[3] + hex[4]).to_i(16))/255.0
    b = ((hex[5] + hex[6]).to_i(16))/255.0
    rgb = [r, g, b]

    min = rgb.min
    max = rgb.max
    delta = max - min

    if delta == 0
      h = 0
    elsif max == r
      h = ((g - b) / delta) % 6
    elsif max == g
      h = (b - r) / delta + 2
    else
      h = (r - g) / delta + 4
    end

    h = (h*60).round
    h += 360 if h < 0

    l = (max + min) / 2;
    s = (delta == 0) ? 0 : delta / (1 - (2 * l - 1).abs)
    s = +(s * 100).round

    "hsl(#{h}, #{s}%, 43%)"
  end

  def get_color
    hex_color = '#' + Digest::MD5.hexdigest(self.email)[0..5]
    return hsl_user_color hex_color
  end


  def get_user_scores_year(requirement_id, period)
    month, year = period.to_date.month, period.to_date.year
    requirement = Requirement.find_by! id: requirement_id

    if [11, 12].include? month
      year += 1
    end

    start_month = Date.new.change(month: 11, year: year - 1)
    end_month   = Date.new.change(month: 10, year: year)

    scores = self.user_scores.where(period: start_month..end_month, requirement: requirement, score_type: 'Bônus').sum(&:score)
    scores -= self.user_scores.where(period: start_month..end_month, requirement: requirement, score_type: 'Penalidade').sum(&:score)
    scores = requirement.max if scores > requirement.max

    return scores.to_f
  end

  def get_user_scores_amount_semester(period, requirement_id)
    year, semester = period.split('.')
    requirement = Requirement.find_by! id: requirement_id

    start_month = Date.new.change(month: 11, year: year.to_i - 1)
    end_month   = Date.new.change(month: 10, year: year.to_i)

    total = self.user_scores.where(period: start_month..end_month.end_of_month, requirement_id: requirement_id, score_type: 'Bônus').sum(&:quantity)
    # total = self.user_scores.where(period: start_month..end_month.end_of_month, requirement_id: requirement_id, score_type: 'Bônus').sum(&:value) if total == 0

    return total
  end

  def get_user_scores_semester(period, requirement_id = nil)
    year, semester = period.split('.')

    start_month = Date.new.change(month: 11, year: year.to_i - 1)
    end_month   = Date.new.change(month: 10, year: year.to_i)

    if requirement_id
      requirement = Requirement.find_by id: requirement_id

      score = self.user_scores.where(period: start_month..end_month.end_of_month, requirement: requirement, score_type: 'Bônus').sum(&:score)
      score -= self.user_scores.where(period: start_month..end_month.end_of_month, requirement: requirement, score_type: 'Penalidade').sum(&:score)
      score = requirement.max if score > requirement.max

      return score.to_f
    else
      group = self.user_scores.where(period: start_month..end_month.end_of_month).group_by(&:requirement_id)

      total = 0
      group.each do |_, scores|
        if scores.is_a?(Array)
          bonus   = scores.select { |us| us.score_type == 'Bônus' }.sum(&:score)
          penalty = scores.select { |us| us.score_type == 'Penalidade' }.sum(&:score)

          current_requirement = scores.first.requirement
          requirement_total = bonus - penalty


          if requirement_total > current_requirement.max
            total += current_requirement.max
          elsif requirement_total < 0
            total += 0
          else
            total += requirement_total
          end
        else
          if scores.score_type == 'Penalidade'
            total += 0
          elsif scores.score_type == 'Bônus' and scores.score < scores.requirement.max
            total += scores.score
          elsif scores.score_type == 'Bônus' and scores.score >= scores.requirement.max
            total += scores.requirement.max
          end
        end
      end

      return total.to_f
    end
  end

  def get_user_scores_amount_month(period, month_index, requirement_id)
    year, period = period.split('.')
    year, period = year.to_i, period.to_i

    months = {
      1 => ["Nov", "Dec", "Jan", "Feb", "Mar", "Apr"],
      2 => ["May", "Jun", "Jul", "Aug", "Sep", "Oct"]
    }

    month = months[period][month_index]

    if (period == 1) and (month_index == 0 or month_index == 1)
      year -= 1
    end

    user_scores = self.user_scores.where(
                    'extract(year from period) = ? and extract(month from period) = ?', year, Date.parse(month).month
                  ).where(requirement_id: requirement_id, score_type: 'Bônus')

    amount = 0

    if user_scores.present? and user_scores.first.quantity
      amount = user_scores.sum(&:quantity)
    elsif user_scores.present? and user_scores.first.value
      amount = user_scores.sum(&:value)
    end

    return amount
  end

  def get_user_scores_month(period, month_index, requirement_id = nil)
    year, period = period.split('.')
    year, period = year.to_i, period.to_i

    months = {
      1 => ["Nov", "Dec", "Jan", "Feb", "Mar", "Apr"],
      2 => ["May", "Jun", "Jul", "Aug", "Sep", "Oct"]
    }

    month = months[period][month_index]

    if (period == 1) and (month_index == 0 or month_index == 1)
      year -= 1
    end

    if requirement_id
      requirement = Requirement.find_by! id: requirement_id

      score = self.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', year, Date.parse(month).month).
            where(requirement_id: requirement_id, score_type: 'Bônus').sum(&:score)
      score -= self.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', year, Date.parse(month).month).
            where(requirement_id: requirement_id, score_type: 'Penalidade').sum(&:score)
      score = requirement.max if score > requirement.max

      return score.to_f
    else
      group = self.user_scores.where('extract(year from period) = ? and extract(month from period) = ?', year, Date.parse(month).month).group_by(&:requirement_id)

      total = 0
      group.each do |_, scores|
        if scores.is_a?(Array)
          bonus   = scores.select { |us| us.score_type == 'Bônus' }.sum(&:score)
          penalty = scores.select { |us| us.score_type == 'Penalidade' }.sum(&:score)

          current_requirement = scores.first.requirement
          requirement_total = bonus - penalty


          if requirement_total > current_requirement.max
            total += current_requirement.max
          elsif requirement_total < 0
            total += 0
          else
            total += requirement_total
          end
        else
          if scores.score_type == 'Penalidade'
            total += 0
          elsif scores.score_type == 'Bônus' and scores.score < scores.requirement.max
            total += scores.score
          elsif scores.score_type == 'Bônus' and scores.score >= scores.requirement.max
            total += scores.requirement.max
          end
        end
      end

      return total.to_f
    end
  end

  def get_current_ranking
    ranking_list = []

    if [11, 12].include? Date.today.month
      start_month = Date.new.change(:month => 11, :year => Date.today.year)
      end_month   = Date.new.change(:month => 10, :year => Date.today.year + 1)
    else
      start_month = Date.new.change(:month => 11, :year => Date.today.year - 1)
      end_month   = Date.new.change(:month => 10, :year => Date.today.year)
    end

    user_ids = UserScore.pluck(:user_id).uniq

    user_ids.each do |id|
      user         = User.find_by_id id
      scores       = user.user_scores.where(period: start_month..end_month.end_of_month).sum(:score)
      ranking_list << [id, scores] if scores > 0
    end

    ranking_list = ranking_list.sort {|a, b| b[1] <=> a[1]}

    rank = 1

    ranking_list.each do |k, v|
      if k == self.id
        return rank
      end

      rank += 1
    end

    return 0
  end

  def get_accomplished_enterprise_total_month(month, year, filter = {})
    total = 0

    enterprises_ids = self.enterprises.where(filter).pluck(:id)
    total = Report.where(planning: 'accomplished', enterprise_id: enterprises_ids, report_type: 'enterprise').where('extract(month from period) = ? AND extract(year from period) = ?', month, year).sum(:amount)
  end

  def get_planned_enterprise_total_month(month, year, filter = {})
    total = 0

    self.enterprises.where(filter).each do |enterprise|
      total += enterprise.reports.where(planning: 'planned').where('extract(month from period) = ? AND extract(year from period) = ?', month, year).sum(:amount)
    end

    return total
  end

  def get_percentage_planning_enterprise_total(month, year, filter = {})
    accomplished = self.get_accomplished_enterprise_total_month(month, year, filter)
    planned      = self.get_planned_enterprise_total_month(month, year, filter)

    return '0.0 %' if planned == 0
    return ((accomplished / planned) * 100).round(2).to_s + ' %'
  end

  def get_percentage_planning_enterprise_year(year, filter = {})
    accomplished = self.get_accomplished_enterprise_total_year(year, filter)
    planned      = self.get_planned_enterprise_total_year(year, filter)

    return 0.0 if planned == 0
    return ((accomplished / planned) * 100).round(2)
  end

  def get_accomplished_enterprise_total_year(year, filter = {})
    total = 0

    enterprises_ids = Enterprise.where(filter).pluck(:id)
    total = Report
            .where(enterprise_id: enterprises_ids,
                   planning: 'accomplished',
                   user_id: self.id,
                   report_type: 'enterprise')
            .where('extract(year from period) = ?', year)
            .sum(:amount)

    return total
  end

  def get_planned_enterprise_total_year(year, filter = {})
    total = 0

    enterprises_ids = Enterprise.where(filter).pluck(:id)
    total = Report.where(enterprise_id: enterprises_ids, planning: 'planned', user_id: self.id).where('extract(year from period) = ?', year).sum(:amount)

    return total
  end

  def get_criterion_status(year, criterion_type)
    criterion = self.score_criterions.where(year: year, criterion_type: criterion_type).first

    if criterion
      return criterion.status
    else
      return false
    end
  end

  def get_enterprises_team
    return Enterprise.where(user_id: User.where(team: self.team).pluck(:id))
  end
end
