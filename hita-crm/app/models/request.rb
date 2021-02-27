class Request < ApplicationRecord
  before_create :set_default_values
  after_create :create_initial_process

  belongs_to :enterprise
  belongs_to :user
  belongs_to :collaborator, optional: true
  belongs_to :technician, class_name: 'User', foreign_key: 'technician_id', optional: true
  belongs_to :draft_owner, class_name: 'User', foreign_key: 'draft_owner_id', optional: true
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id', optional: true
  belongs_to :equipment, optional: true

  has_many :request_products, dependent: :destroy
  has_many :hindrances, dependent: :destroy
  has_many :interactions, dependent: :destroy
  has_many :request_quiz_data, dependent: :destroy, class_name: 'RequestQuizData', foreign_key: 'request_id'
  has_many :request_proposals, dependent: :destroy
  has_many :request_installments, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :request_conditions, dependent: :destroy
  


  has_many_attached :files, dependent: :destroy
  has_many_attached :calculation_memorials, dependent: :destroy
  has_many_attached :photos_reports, dependent: :destroy
  has_many_attached :procedures, dependent: :destroy
  has_many_attached :success_certificates, dependent: :destroy
  has_many_attached :execution_certificates, dependent: :destroy
  has_many_attached :fs, dependent: :destroy
  has_many_attached :qsc, dependent: :destroy
  has_many_attached :rdo, dependent: :destroy
  has_many_attached :financial_files, dependent: :destroy

  serialize :equipment_sizes, Array
  serialize :cause_or_reason, Array
  serialize :solutions, Array
  serialize :fluids, Array

  PRODUCT_STEPS = {
    in_line: 1,
    elaboration: 2,
    approval: 3,
    revenue: 4,
    mobilization: 5,
    payment: 6,
    finished: 7
  }.freeze

  SERVICES_STEPS = {
    in_line: 1,
    elaboration: 2,
    approval: 3,
    mobilization: 4,
    execution: 5,
    revenue: 6,
    payment: 7,
    aftersale: 8,
    finished: 9
  }.freeze

  searchable do
    integer :enterprise_id
    integer :request_code, multiple: true
    string :cause_or_reason, multiple: true
    string :solutions, multiple: true
    string :substratum, multiple: true
    string :surface_preparation
    string :fluids, multiple: true

    string :equipment do
      equipment.nil? ? nil : equipment.name
    end

    string :enterprise_segment do
      enterprise.nil? ? nil : enterprise.industry_sector
    end

    string :enterprise_state do
      enterprise.nil? ? nil : enterprise.state
    end

    string :enterprise_city do
      enterprise.nil? ? nil : enterprise.city
    end

    boolean :is_draft
    double :pressure_proj
    double :pressure_opr
    double :temperature_proj
    double :temperature_opr
    time   :created_at, trie: true
  end

  def current_step
    return self.current_product_step if self.request_type == 'product'
    return self.current_service_step if self.request_type == 'service'
  end

  def current_product_step
    case self.step
    when 1
      'Fila'
    when 2
      'Elaboração'
    when 3
      'Aprovação'
    when 4
      'Faturamento'
    when 5
      'Mobilização'
    when 6
      'Pagamento'
    else
      'Concluído'
    end
  end

  def current_service_step
    case self.step
    when 1
      'Fila'
    when 2
      'Elaboração'
    when 3
      'Aprovação'
    when 4
      'Mobilização'
    when 5
      'Execução'
    when 6
      'Faturamento'
    when 7
      'Pagamento'
    when 8
      'Pós-venda'
    else
      'Concluído'
    end
  end

  def current_stage
    if self.step
      if self.request_type == 'product'
        return 'in_line'      if self.step == 1
        return 'elaboration'  if self.step == 2
        return 'approval'     if self.step == 3
        return 'revenue'      if self.step == 4
        return 'mobilization' if self.step == 5
        return 'payment'      if self.step == 6
        return 'finished'     if self.step == 7
      else
        return 'in_line'      if self.step == 1
        return 'elaboration'  if self.step == 2
        return 'approval'     if self.step == 3
        return 'mobilization' if self.step == 4
        return 'execution'    if self.step == 5
        return 'revenue'      if self.step == 6
        return 'payment'      if self.step == 7
        return 'aftersale'    if self.step == 8
        return 'finished'     if self.step == 9
      end
    end
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

  def detainees_number
    hindrances = self.hindrances
    return "#{hindrances.last.detainee.name} e + #{hindrances.size - 1}" if hindrances.present? and (hindrances.size - 1) > 0
    return "#{hindrances.last.detainee.name}" if hindrances.present?
    "Nenhum Impedimento"
  end

  def get_request_quiz_data
    request_quiz_data = []
    self.request_quiz_data.each do |request_quiz|
      request_quiz_data << request_quiz.data.as_json
    end

    return request_quiz_data
  end

  def get_total_shipping
    return self.request_products.sum(:shipping_price)
  end

  def calculate_priority_percentage
    final_priority = 0
    enterprise_revenue = self.enterprise.revenue.to_f

    final_priority =
    if enterprise_revenue < 100000.0
      0.1
    elsif enterprise_revenue > 100000.0 and enterprise_revenue < 500000.0
      0.2
    else
      0.3
    end


    if self.response_time
      days_until_response = (self.response_time - Date.today).to_i

      final_priority +=
      if days_until_response > 5
        0.0
      elsif days_until_response < 0
        0.5
      else
        0.5 - (0.1*(days_until_response)).round(2)
      end
    end


    final_priority +=
    case self.calculate_request_revenue
    when 0..20000.0
      0.05
    when 20000.1..100000.0
      0.1
    when 100000.1..500000.0
      0.15
    else
      0.2
    end

    return final_priority
  end

  def calculate_priority
    final_priority = calculate_priority_percentage

    case final_priority
    when 0..0.25
      return 'low'
    when 0.26..0.50
      return 'medium'
    when 0.51..0.75
      return 'high'
    else
      return 'max'
    end
  end

  def is_request_billed?
    return self.request_installments.empty? ? self.is_billed : !self.request_installments.exists?(is_billed: false)
  end

  def get_request_code
    return '' if self.request_code.nil?
    return self.request_code.to_s.rjust(6, '0')
  end

  def calculate_request_revenue
    total_value = 0

    total_value += self.value_estimation if self.value_estimation

    self.request_products.each do |product|
      total_value += product.price_with_discount.nil? ? product.calculated_price : product.price_with_discount
      total_value += product.shipping_price if product.shipping_price
    end

    return total_value.to_f
  end

  def get_current_status
    if self.is_active and self.current_stage == 'finished'
      return 'Finalizado'
    end

    return 'Arquivado' if self.is_active == false
    return self.current_step
  end

  def request_products_for_api
    request_products.map do |r|
      {
        id: r.id,
        product_quantity: r.product_quantity,
        product_code: r.product.code,
        request_id: r.request_id,
        product_id: r.product_id,
        shipping_price: r.shipping_price,
        calculated_price: r.calculated_price,
        price_with_discount: r.price_with_discount
      }
    end
  end

private

  def set_default_values
    self.step = 1

    last_request = Request.all.order(request_code: :asc).last

    self.request_code =
    if last_request
      last_request.request_code + 1
    else
      40001
    end
  end

  def create_initial_process
    interaction_params = {
      current: 'request',
      content: "O pedido <b>##{self.get_request_code}</b> entrou na fila para ser avaliado",
      request_id: self.id,
      request_type: self.request_type
    }

    InteractionHelper.create 'in_line', interaction_params

    if self.is_draft == false
      technical_managers = User.where(role: User::ROLES[:technical_manager], is_active: true)
      technical_managers.each do |manager|
        hindrance_params = {
          detainee_id: manager.id,
          request_id: self.id
        }

        HindrancesHelper.create_hindrance(hindrance_params)
      end
    end
  end
end
