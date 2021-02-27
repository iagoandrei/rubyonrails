class Hindrance < ApplicationRecord
  before_create :set_default_values

  belongs_to :detainee, class_name: 'User', foreign_key: 'user_id'
  belongs_to :deterrent, class_name: 'User', foreign_key: 'created_by', optional: true
  belongs_to :request

  def elapsed_time_since_updated
    seconds_diff = (Time.now - self.updated_at).to_i.abs

    hours = seconds_diff / 3600
    days = (hours/24).to_i
    hours_mod = hours % 24

    seconds_diff -= hours * 3600

    minutes = seconds_diff / 60

    "#{days}d #{hours_mod}h #{minutes}m"
  end

  def elapsed_time_since_created
    seconds_diff = (Time.now - self.created_at).to_i.abs

    hours = seconds_diff / 3600
    days = (hours/24).to_i
    hours_mod = hours % 24

    seconds_diff -= hours * 3600

    minutes = seconds_diff / 60

    "#{days}d #{hours_mod}h #{minutes}m"
  end

  private

  def set_default_values
    self.is_active = true
  end
end
