module ReportsHelper
  def self.create(params = {})
    enterprise   = Enterprise.find_by_id params[:enterprise_id]
    year         = params[:year].to_i
    report_type  = params[:report_type]
    month_number = params[:month_number].to_i
    request      = Request.find_by_id params[:request_id]
    installment  = RequestInstallment.find_by_id params[:installment_id] if params[:installment_id].present?

    if report_type == 'planned'
      period_type = params[:period_type]
      amount      = params[:amount].tr('.', '').tr(',', '.').to_f

      if amount == 0
        Report.where(enterprise_id: enterprise.id, planning: 'planned').where('extract(year from period) = ?', year).destroy_all

        return true
      else
        if period_type == 'month'
          report = enterprise.reports.where('extract(month from period) = ? AND extract(year from period) = ?', month_number, year).where(planning: 'planned', report_type: 'enterprise').first

          if report
            report.update_attribute(:amount, amount)
          else
            report             = Report.new
            report.enterprise  = enterprise
            report.amount      = amount
            report.planning    = report_type
            report.period      = Date.new.change(:month => month_number, :year => year)
            report.user        = enterprise.user
            report.request     = request
            report.report_type = 'enterprise'
            report.save
          end

          # 'Líder de Vendas Mensal' META ANUAL

          requirement = Requirement.find_by_title 'Meta Anual'
          UserScore.where('extract(year from period) = ?', year)
                   .where(requirement_id: requirement.id, user_id: enterprise.user.id).destroy_all

          goal = enterprise.get_percentage_planning_year(year).to_f

          if goal >= 100.0
            user_score_params = {
              current_user_id: enterprise.user.id,
              requirement_title: 'Meta Anual',
              current_date: Date.new.change(:month => month_number, :year => year)
            }

            UserScoresHelper.create user_score_params
          end

          # 'Líder de Vendas Mensal' REGULARIDADE MENSAL

          requirement = Requirement.find_by_title 'Regularidade Mensal'
          UserScore.where('extract(year from period) = ? AND extract(month from period) = ?', year, month_number)
                   .where(requirement_id: requirement.id, user_id: enterprise.user.id).destroy_all

          goal = enterprise.get_percentage_planning(month_number, year).to_f

          if goal >= 100.0
            user_score_params = {
              current_user_id: enterprise.user.id,
              requirement_title: 'Regularidade Mensal',
              current_date: Date.new.change(:month => month_number, :year => year)
            }

            UserScoresHelper.create user_score_params
          end
        else
          # 'Líder de Vendas Mensal' META ANUAL

          requirement         = Requirement.find_by_title 'Meta Anual'
          requirement_monthly = Requirement.find_by_title 'Regularidade Mensal'

          Report.where(enterprise_id: enterprise.id, planning: report_type, report_type: 'enterprise').destroy_all
          UserScore.where('extract(year from period) = ?', year).where(requirement_id: [requirement.id, requirement_monthly], user_id: enterprise.user.id).destroy_all

          12.times do |i|
            Report.create(amount: amount / 12, planning: report_type, period: Date.new.change(:month => i + 1, :year => year), enterprise_id: enterprise.id, user_id: enterprise.user.id, report_type: 'enterprise')

            goal         = enterprise.get_percentage_planning_year(year).to_f
            goal_monthly = enterprise.get_percentage_planning(i + 1, year).to_f

            if goal >= 100.0
              user_score_params = {
                current_user_id: enterprise.user.id,
                requirement_title: 'Meta Anual',
                current_date: Date.new.change(:month => i + 1, :year => year)
              }

              UserScoresHelper.create user_score_params
            end

            if goal_monthly >= 100.0
              user_score_params = {
                current_user_id: enterprise.user.id,
                requirement_title: 'Regularidade Mensal',
                current_date: Date.new.change(:month => i + 1, :year => year)
              }

              UserScoresHelper.create user_score_params
            end
          end

          return true
        end
      end
    else
      report             = Report.new
      report.enterprise  = enterprise
      report.period      = report.period = Date.new.change(:month => month_number, :year => year)
      report.amount      = params[:amount]
      report.planning    = report_type
      report.user        = enterprise.user
      report.request     = request
      report.report_type = 'enterprise'
      report.request_installment = installment if params[:installment_id].present?
      report.save

      # 'Líder de Vendas Mensal' META ANUAL

      requirement = Requirement.find_by_title 'Meta Anual'
      UserScore.where('extract(year from period) = ?', year)
               .where(requirement_id: requirement.id, user_id: enterprise.user.id).destroy_all

      goal = enterprise.get_percentage_planning_year(year).to_f

      if goal >= 100.0
        user_score_params = {
          current_user_id: enterprise.user.id,
          requirement_title: 'Meta Anual',
          current_date: Date.new.change(:month => month_number, :year => year)
        }

        UserScoresHelper.create user_score_params
      end

      # 'Líder de Vendas Mensal' REGULARIDADE MENSAL

      requirement = Requirement.find_by_title 'Regularidade Mensal'
      UserScore.where('extract(year from period) = ? AND extract(month from period) = ?', year, month_number)
               .where(requirement_id: requirement.id, user_id: enterprise.user.id).destroy_all

      goal = enterprise.get_percentage_planning(month_number, year).to_f

      if goal >= 100.0
        user_score_params = {
          current_user_id: enterprise.user.id,
          requirement_title: 'Regularidade Mensal',
          current_date: Date.new.change(:month => month_number, :year => year)
        }

        UserScoresHelper.create user_score_params
      end

      # 'Líder de Vendas Mensal' LÍDER DE VENDAS MENSAL

      requirement = Requirement.find_by_title 'Líder de Vendas Mensal'
      UserScore.where('extract(year from period) = ? and extract(month from period) = ?', year, month_number)
               .where(requirement_id: requirement.id).destroy_all

      max_invoicing = get_highest_monthly_invoicing(month_number, year)

      User.all.each do |user|
        max_invoicing_user = get_highest_monthly_invoicing(month_number, year, user.id)

        if max_invoicing_user > 0
          user_score_params = {
            current_user_id: user.id,
            requirement_title: 'Líder de Vendas Mensal',
            current_date: Date.new.change(:month => month_number, :year => year),
            score: (max_invoicing_user.to_f / max_invoicing) * 1.5
          }

          UserScoresHelper.create user_score_params
        end
      end
    end

    report.save ? report.id : false
  end

  def self.create_product(params = {})
    product      = Product.find_by_id params[:product_id]
    amount       = params[:amount]
    year         = params[:year].to_i
    month_number = params[:month_number].to_i
    enterprise   = Enterprise.find_by_id params[:enterprise_id]
    request      = Request.find_by_id params[:request_id]
    installment  = RequestInstallment.find_by_id params[:installment_id] if params[:installment_id].present?

    report             = Report.new
    report.product     = product
    report.amount      = amount
    report.planning    = 'accomplished'
    report.period      = Date.new.change(:month => month_number, :year => year)
    report.user        = enterprise.user
    report.request     = request
    report.enterprise  = enterprise
    report.report_type = request.request_type
    report.request_installment = installment if params[:installment_id].present?

    report.save ? report.id : false
  end

  def self.create_shipping(params = {})
    amount       = params[:amount]
    year         = params[:year].to_i
    month_number = params[:month_number].to_i
    request      = Request.find_by_id params[:request_id]
    installment  = RequestInstallment.find_by_id params[:installment_id] if params[:installment_id].present?

    product            = Product.find_by_name 'Frete'
    report             = Report.new
    report.product     = product
    report.period      = Date.new.change(:month => month_number, :year => year)
    report.planning    = 'accomplished'
    report.user        = request.enterprise.user
    report.report_type = request.request_type
    report.amount      = amount
    report.request     = request
    report.enterprise  = request.enterprise
    report.request_installment = installment if params[:installment_id].present?

    report.save ? report.id : false
  end

  def self.create_service(params = {})
    amount       = params[:amount]
    year         = params[:year].to_i
    month_number = params[:month_number].to_i
    request      = Request.find_by_id params[:request_id]
    installment  = RequestInstallment.find_by_id params[:installment_id] if params[:installment_id].present?

    product            = Product.find_by_name 'Valor Serviço'
    report             = Report.new
    report.product     = product
    report.period      = Date.new.change(:month => month_number, :year => year)
    report.planning    = 'accomplished'
    report.user        = request.enterprise.user
    report.report_type = request.request_type
    report.amount      = amount
    report.request     = request
    report.enterprise  = request.enterprise
    report.request_installment = installment if params[:installment_id].present?

    report.save ? report.id : false
  end

  # Products

  def self.show_product_accomplished_month_total(year, month, product_ids, enterprise_filter = {}, request_type)
    total          = 0
    enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)

    product_ids << Product.find_by_name('Frete').id
    product_ids << Product.find_by_name('Valor Serviço').id

    # Product.where(id: product_ids).each do |product|
    #   total += product.reports.where(planning: 'accomplished', enterprise_id: enterprise_ids, report_type: request_type).where('extract(month from period) = ? AND extract(year from period) = ?', month, year).sum(:amount)
    # end

    total = Report.where(product_id: product_ids, planning: 'accomplished', enterprise_id: enterprise_ids, report_type: request_type).where('extract(month from period) = ? AND extract(year from period) = ?', month, year).sum(:amount)

    return total
  end

  def self.show_product_accomplished_year_total(year, product_ids, enterprise_filter = {}, request_type)
    total          = 0
    enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)

    product_ids << Product.find_by_name('Frete').id
    product_ids << Product.find_by_name('Valor Serviço').id

    Product.where(id: product_ids).each do |product|
      total += product.reports.where(planning: 'accomplished', enterprise_id: enterprise_ids, report_type: request_type).where('extract(year from period) = ?', year).sum(:amount)
    end

    return total
  end

  def self.show_product_contribuition_year_total(year, product_ids, filter = {}, enterprise_filter = {}, request_type)
    total = 0

    Product.where(filter).each do |product|
      total += product.get_contribution(year, filter, enterprise_filter, request_type)
    end

    return total
  end

  # Enterprises

  def self.show_enterprise_accomplished_month_total(year, month, enterprise_ids = nil)
    if enterprise_ids.length == 0
      return 0
    end

    total =
    if enterprise_ids.present?
      Report
        .where(enterprise_id: enterprise_ids, planning: 'accomplished', report_type: 'enterprise')
        .where('extract(month from period) = ? AND extract(year from period) = ?', month, year)
        .sum(:amount)
    else
      Report
        .where(planning: 'accomplished', report_type: 'enterprise')
        .where('extract(month from period) = ? AND extract(year from period) = ?', month, year)
        .sum(:amount)
    end

    return total
  end

  def self.show_enterprise_percentage_planning_month_total(year, month, enterprise_ids)
    total = 0

    Enterprise.where(id: enterprise_ids).each do |enterprise|
      total += enterprise.get_percentage_planning(month, year)
    end

    return total
  end

  def self.show_enterprise_planned_month_total(year, month, enterprise_ids = nil)
    # total = 0

    # Enterprise.where(id: enterprise_ids).each do |enterprise|
    #   total += enterprise.reports.where(planning: 'planned', report_type: 'enterprise').where('extract(month from period) = ? AND extract(year from period) = ?', month, year).sum(:amount)
    # end

    total =
    if enterprise_ids.present?
      Report
        .where(enterprise_id: enterprise_ids, planning: 'planned', report_type: 'enterprise')
        .where('extract(month from period) = ? AND extract(year from period) = ?', month, year)
        .sum(:amount)
    else
      Report
        .where(planning: 'planned', report_type: 'enterprise')
        .where('extract(month from period) = ? AND extract(year from period) = ?', month, year)
        .sum(:amount)
    end

    return total
  end

  def self.show_enterprise_planned_year_total(year, enterprise_ids)
    total = 0

    Enterprise.where(id: enterprise_ids).each do |enterprise|
      total += enterprise.reports.where(planning: 'planned', report_type: 'enterprise').where('extract(year from period) = ?', year).sum(:amount)
    end

    return total
  end

  def self.show_enterprise_accomplished_year_total(year, enterprise_ids)
    total = 0

    Enterprise.where(id: enterprise_ids).each do |enterprise|
      total += enterprise.reports.where(planning: 'accomplished', report_type: 'enterprise').where('extract(year from period) = ?', year).sum(:amount)
    end

    return total
  end

  def self.show_enterprise_contribuition_year_total(year, filter = {})
    total = 0

    Enterprise.where(filter).each do |enterprise|
      total += enterprise.get_contribution(year, filter)
    end

    return total
  end

  def self.show_enterprise_percentage_planning_year_total(year, filter = {})
    total = 0

    Enterprise.where(filter).each do |enterprise|
      total += enterprise.get_percentage_planning_year(year)
    end

    return total
  end

  def self.get_highest_monthly_invoicing(month, year, user_id = nil)
    params      = {}
    params[:id] = user_id if user_id
    params[:is_active] = true
    max         = 0

    User.where(params).each do |user|
      reports = Report.where(user: user)

      amount = reports.where('extract(month from period) = ? AND extract(year from period) = ?', month, year).where(product: nil, planning: 'accomplished').sum(&:amount)
      max = amount if amount > max
    end

    return max
  end

  def self.show_products_quantity_total_year(year, product_ids, enterprise_filter = {}, request_type)
    total          = 0
    enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)
    products       = Product.where(id: product_ids)

    products.each do |product|
      reports = product.reports.where(enterprise_id: enterprise_ids, report_type: request_type).where('extract(year from period) = ?', year)

      reports.each do |report|
        total += report.request.request_products.where(product_id: product.id).sum(:product_quantity)
      end
    end

    return total
  end

  # def self.show_products_quantity_total_month(month, year, product_ids, enterprise_filter = {}, request_type)
  #   total          = 0
  #   enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)
  #   products       = Product.where(id: product_ids)

  #   products.each do |product|
  #     reports = product.reports.where(enterprise_id: enterprise_ids, report_type: request_type).where('extract(month from period) = ? AND extract(year from period) = ?', month, year)

  #     reports.each do |report|
  #       total += report.request.request_products.where(product_id: product.id).sum(:product_quantity)
  #     end
  #   end

  #   return total
  # end


  def self.show_products_quantity_total_month(month, year, product_ids, enterprise_filter = {}, request_type)
    total = 0
    enterprise_ids = Enterprise.where(enterprise_filter).pluck(:id)

    requests_ids = Report.where(enterprise_id: enterprise_ids, report_type: request_type, product_id: product_ids).where('extract(month from period) = ? AND extract(year from period) = ?', month, year).pluck(:request_id)
    total = RequestProduct.where(request_id: requests_ids).sum(:product_quantity)

    return total
  end
end
