class Product < ApplicationRecord
  before_create :set_default_values

  has_many :reports
  has_many :request_products

  def get_accomplished_month(month, year, enterprise_filter = {}, request_type)
    enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)

    return self.reports.where(planning: 'accomplished', enterprise_id: enterprise_ids, report_type: request_type).where('extract(month from period) = ? AND extract(year from period) = ?', month, year).sum(:amount)
  end

  def get_accomplished_year(year, enterprise_filter = {}, request_type)
    enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)

    return self.reports.where(planning: 'accomplished', enterprise_id: enterprise_ids, report_type: request_type).where('extract(year from period) = ?', year).sum(:amount)
  end

  def get_contribution(year, filter = {}, enterprise_filter = {}, request_type)
    total          = 0
    enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)
    accomplished   = self.get_accomplished_year(year, enterprise_filter, request_type)

    Product.where(filter).each do |product|
      total += product.reports.where(planning: 'accomplished', enterprise_id: enterprise_ids, report_type: request_type).where('extract(year from period) = ?', year).sum(:amount)
    end

    return 0.0 if total == 0
    return ((accomplished / total) * 100).round(2)
  end

  def calculate_yara_value
    dollar_value = Product.last.current_dollar_price

    return nil if yara_price == ''

    begin
      yara_expression = self.yara_price.gsub('dolar', dollar_value.to_s)
      parsed_value = eval(yara_expression)
    rescue SyntaxError
      return nil
    rescue
      return nil
    end

    return parsed_value
  end

  def get_product_price table
    fob_table_value = (self.dollar_price * self.current_dollar_price).ceil

    case table
    when 'fob_table'
      return fob_table_value
    when 'braskem_table'
      return self.braskem_price.ceil if self.braskem_price
      return fob_table_value
    when 'braskem_sp_table'
      return self.braskem_sp_price.ceil if self.braskem_sp_price
      return fob_table_value
    when 'yara_table'
      return self.calculate_yara_value.ceil if self.yara_price
      return fob_table_value
    when 'mosaic_table'
      return self.mosaic_price.ceil if self.mosaic_price
      return fob_table_value
    when 'vale_mining_table'
      return self.vale_mining_price.ceil if self.vale_mining_price
      return fob_table_value
    when 'anglo_american_table'
      return self.anglo_american_price.ceil if self.anglo_american_price
      return fob_table_value
    when 'arcelor_table'
      return self.arcelor_price.ceil if self.arcelor_price
      return fob_table_value
    when 'modec_table'
      return self.modec_price.ceil if self.modec_price
      return fob_table_value
    when 'petrobras_table'
      return self.petrobras_price.ceil if self.petrobras_price
      return fob_table_value
    else
      return fob_table_value
    end
  end

  def get_product_quantity_year_request(year, enterprise_filter = {}, request_type)
    total          = 0
    enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)
    reports        = self.reports.where(enterprise_id: enterprise_ids, report_type: request_type).where('extract(year from period) = ?', year)

    if self.name == 'Frete' or self.name == 'Valor Serviço'
      total += reports.size
    else
      reports.each do |report|
        total += report.request.request_products.where(product_id: self.id).sum(:product_quantity)
      end
    end

    return total
  end

  # def get_product_quantity_month_request(month, year, enterprise_filter = {}, request_type)
  #   total          = 0
  #   enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)
  #   reports        = self.reports.where(enterprise_id: enterprise_ids, report_type: request_type).where('extract(month from period) = ? AND extract(year from period) = ?', month, year)

  #   if self.name == 'Frete' or self.name == 'Valor Serviço'
  #     total += reports.size
  #   else
  #     reports.each do |report|
  #       total += report.request.request_products.where(product_id: self.id).sum(:product_quantity)
  #     end
  #   end

  #   return total
  # end

  def get_product_quantity_month_request(month, year, enterprise_filter = {}, request_type)
    total          = 0
    enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)
    reports        = self.reports.where(enterprise_id: enterprise_ids, report_type: request_type).where('extract(month from period) = ? AND extract(year from period) = ?', month, year)

    if self.name == 'Frete' or self.name == 'Valor Serviço'
      total += reports.size
    else
      requests_ids = reports.pluck(:request_id)
      total = RequestProduct.where(request_id: requests_ids, product_id: self.id).sum(:product_quantity)

      # reports.each do |report|
      #   total += report.request.request_products.where(product_id: self.id).sum(:product_quantity)
      # end
    end

    return total
  end

private

  def set_default_values
    self.current_dollar_price = Product.last&.current_dollar_price || 0
  end
end
