class Enterprise < ApplicationRecord
  before_create :set_default_values

  belongs_to :user
  has_many :collaborator, dependent: :destroy
  has_many :interactions, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many_attached :flow_charts, dependent: :destroy
  has_many_attached :organization_charts, dependent: :destroy
  has_many_attached :files, dependent: :destroy
  has_one :old_enteprise_interaction, class_name: 'Interaction', foreign_key: 'enterprise_changed_old', dependent: :destroy
  has_one :new_enteprise_interaction, class_name: 'Interaction', foreign_key: 'enterprise_changed_new', dependent: :destroy
  has_many :requests
  has_many :reports

  PRICE_TABLE = {
    fob_table: 'Geral FOB',
    braskem_table: 'Braskem BA, RS, AL',
    braskem_sp_table: 'Braskem SP',
    yara_table: 'Vale Fertilizante (Yara)  Tabela/(1-0,0725)',
    mosaic_table: 'Mosaic',
    vale_mining_table: 'Vale Mineração',
    anglo_american_table: 'Anglo American',
    arcelor_table: 'Arcelor',
    modec_table: 'Modec',
    petrobras_table: 'Petrobrás'
  }.freeze

  def complete_address
    adr = ""
    adr += "#{self.address}, " if self.address
    adr += "#{self.city}, " if self.city
    adr += "#{self.state}, " if self.state
    adr += "#{self.cep}, " if self.cep

    return adr.delete_suffix(', ')
  end

  def count_elaborated_proposals
    return Request.joins(:request_proposals).where("requests.enterprise_id = ?", self.id).size
  end

  def get_accomplished_month(month, year)
    return self.reports.where(planning: 'accomplished', report_type: 'enterprise').where('extract(month from period) = ? AND extract(year from period) = ?', month, year).sum(:amount)
  end

  def get_planned_month(month, year)
    return self.reports.where(planning: 'planned', report_type: 'enterprise').where('extract(month from period) = ? AND extract(year from period) = ?', month, year).sum(:amount)
  end

  def get_accomplished_year(year)
    return self.reports.where(planning: 'accomplished', report_type: 'enterprise').where('extract(year from period) = ?', year).sum(:amount)
  end

  def get_planned_year(year)
    return self.reports.where(planning: 'planned', report_type: 'enterprise').where('extract(year from period) = ?', year).sum(:amount)
  end

  def get_percentage_planning(month, year)
    accomplished = self.get_accomplished_month(month, year)
    planned = self.get_planned_month(month, year)

    return 0.0 if planned == 0
    return ((accomplished / planned) * 100).round(2)
  end

  def get_percentage_planning_year(year)
    accomplished = self.get_accomplished_year(year)
    planned = self.get_planned_year(year)

    return 0.0 if planned == 0
    return ((accomplished / planned) * 100).round(2)
  end

  def get_contribution(year, filter = {})

    if filter
      enterprise_ids    = Enterprise.where(filter).pluck(:id)
      accomplished_year = Report.where(planning: 'accomplished', enterprise_id: enterprise_ids, report_type: 'enterprise').
                                 where('extract(year from period) = ?', year).sum(:amount)
    else
      accomplished_year = Report.where(planning: 'accomplished', report_type: 'enterprise').
                                 where.not(enterprise_id: nil).
                                 where('extract(year from period) = ?', year).sum(:amount)
    end

    accomplished = self.get_accomplished_year(year)

    return 0.0 if accomplished_year == 0
    return ((accomplished / accomplished_year) * 100).round(2)
  end

  def state_uf
    return "#{self.city} - #{self.state}" if self.state.present? and self.city.present?
    return self.city if !self.state.present? and self.city.present?
    return self.state if self.state.present? and !self.city.present?
    return ''
  end

private
  def current_price_table
    return '' if self.price_table.nil?
    return PRICE_TABLE[self.price_table.to_sym]
  end

  private

  def set_default_values
    self.price_table ||= 'fob_table'
  end
end
