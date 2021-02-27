namespace :db_utils do
  desc "Update product database using the sql server container"
  task :update_product_table => :environment do
    require 'net/http'
    require 'uri'

    puts "Iniciando tarefa..."
    uri = URI.parse('http://mssql-api/api/product_complete_infos')
    http = Net::HTTP.new(uri.host, 5656)

    current_products = Product.all.pluck(:code)
    products_on_cigam = []

    puts "Consultando tabela de produtos..."
    res = http.get(uri.path)
    products = JSON.parse(res.body)

    puts "Iniciando atualização de produtos..."
    products.each do |product|
      code = product['code']
      existing_product = Product.find_by code: code
      products_on_cigam << code

      if existing_product
        puts "Produto com codigo #{code} já existe na tabela. Atualizando.."

        existing_product.name = product['name']
        existing_product.unit = product['unit']
        existing_product.ipi = product['ipi']
        existing_product.characteristics = product['characteristics']
        existing_product.income = product['income'].gsub("\r\n", ' ')
        existing_product.ncm = product['ncm']
        existing_product.is_active = true
        existing_product.save
      else
        Product.create(
          name: product['name'],
          code: code,
          unit: product['unit'],
          ipi: product['ipi'],
          characteristics: product['characteristics'],
          income: product['income'].gsub("\r\n", ' '),
          ncm: product['ncm']
        )
        puts "Novo produto com código: #{code}."
      end
    end

    unactive_products = current_products - products_on_cigam

    if unactive_products.length > 0
      puts "Alguns produtos estão marcados como inativos. Os produtos marcados como inativos só aparecerão no sistema em pedidos que utilizaram estes produtos."
      puts "Os seguintes produtos estão marcados como inativos:"

      unactive_products.each do |code|
        product = Product.find_by code: code
        product.is_active = false

        if product.save
          puts "Produto #{code} marcado como inativo."
        end
      end
    end
  end

  desc "This tasks updates the enterprise revenue with the current reports"
  task :update_enterprise_revenue => :environment do
    puts "Iniciando tarefa e zerando faturamento de TODAS as empresas..."
    Enterprise.update_all(revenue: 0)

    installments = RequestInstallment.where(is_billed: true)

    puts "Iniciando calculo de faturamentos atualizados"

    installments.each do |installment|
      current_enterprise = installment.request.enterprise
      current_enterprise.revenue += installment.value
      current_enterprise.save
    end

    puts "Faturamento de empresas foram atualizados."
  end

  desc "This task fixes all wrong request quizzes answers in requests"
  task :update_request_quiz_answers => :environment do
    requests = Request.where(is_draft: false).where.not(equipment_id: nil)

    requests.each do |request|

      puts "-------------------------------------------------------------"
      puts "Parseando pedido: #{request.request_code}"
      puts "-------------------------------------------------------------"
      print_values(request)

      request.request_quiz_data.each do |quiz|
        quiz_data = JSON.parse(quiz.data)
        parse_chatbot_answers(request, quiz_data)
      end

      puts "Novos valores parseados: \n"
      print_values(request)
    end
  end

  desc "This task import all hita enterprises from a CSV"
  task :import_enterprise_data => :environment do
    require 'csv'
    require 'activerecord-import'

    enterprises = []
    CSV.foreach('vendor/dados_hita_empresas_no_dup.csv', headers: true) do |row|
      existance = Enterprise.find_by(cnpj: row.to_h['cnpj']).present?
      cnpj_blank = row.to_h['cnpj'] == ''

      if existance == false or cnpj_blank == true
        enterprises << row.to_h
      end
    end

    puts "#{enterprises.length} novas empresas serão adicionadas."
    puts "Inserindo empresas..."

    Enterprise.import(enterprises)
    puts "Finalizado."
  end

  desc 'This task updates the name of a consultop requirement'
  task :fix_new_defaults_for_consultop => :environment do
    seminar = Requirement.find_by title: 'Palestras ou Seminários'
    seminar&.update(title: 'Seminários ou Treinamentos')
  end

  desc 'Updates all proposal codes from requests'
  task :update_proposal_codes => :environment do
    requests = Request.where(is_draft: false)
    requests.each do |request|
      request.proposal_code = generate_proposal_code(request, request.request_products)
      puts "Pedido: #{request.request_code} - Cod: #{request.proposal_code}"
      request.save
    end
  end

  #### Used functions

  def generate_proposal_code request, products
    equipment = request.equipment

    product = if products and products.size > 0
                aux = products.first
                product = Product.find_by code: aux['code']
              else
                nil
              end

    if equipment.nil? and request.is_stock_replacement
      return "REPO" if product.nil?

      if product.name.downcase.include? 'belzona'
        splitted_name = product.name.split(' ')[1]
        return "REPO_B#{splitted_name[0..3]}" if splitted_name
        return "REPO_B0000"

      elsif product.name.downcase.include? 'gaxeta slade'
        splitted_name = product.name.split(' ')[1]
        return "REPO_S#{splitted_name[0..3]}" if splitted_name
        return "REPO_S0000"

        return "REPO_#{product.name[0..4]}"
      else
        return "REPO_#{product.name[0..4]}"
      end

    elsif equipment and product
      if product.name.downcase.include? 'belzona'
        splitted_name = product.name.split(' ')[1]
        return "#{equipment.name[0..5]}_B#{splitted_name[0..3]}" if splitted_name
        return "#{equipment.name[0..5]}_B0000"

      elsif product.name.downcase.include? 'gaxeta slade'
        splitted_name = product.name.split(' ')[1]
        return "#{equipment.name}_S#{splitted_name[0..3]}" if splitted_name
        return "#{equipment.name}_S0000"

      else
        return "#{equipment.name[0..5]}_#{product.name[0..4]}"
      end
    elsif equipment.nil? and !request.is_stock_replacement
      return ""
    else
      return "#{equipment.name[0..5].upcase.gsub(' ', '_')}"
    end

    return ""
  end


  def parse_chatbot_answers request, parsed_data
    if parsed_data['name'].downcase == 'causa/motivo'
      request.cause_or_reason = parsed_data["questions"][0]["user_answers"].pluck("text")
    end

    if parsed_data['name'].downcase == 'preparação de superfície'
      request.surface_preparation = parsed_data['questions'][0]['user_answers'][0]['text']
    end

    if parsed_data['name'].downcase == 'tag'
      request.tag = parsed_data['questions'][0]['user_answers'][0]['text']
    end

    if parsed_data['name'].downcase == 'substrato'
      request.substratum = parsed_data['questions'][0]['user_answers'][0]['text'].strip
    end

    if parsed_data['name'].downcase == 'soluções'
      request.solutions = parsed_data['questions'][0]['user_answers'].pluck("text")
    end

    if parsed_data['name'].downcase == 'fluido e concentração'
      request.fluids = parse_fluid_data(parsed_data)
    end

    if parsed_data['name'].downcase == 'temperatura'
      parsed_value = parsed_data['questions'][0]['user_answers'][0]['text']
      parsed_value.remove!(' ºC').gsub!(',','.').to_f
      request.temperature_proj = parsed_value

      parsed_value = parsed_data['questions'][1]['user_answers'][0]['text']
      parsed_value.remove!(' ºC').gsub!(',','.').to_f
      request.temperature_opr = parsed_value
    end

    if parsed_data['name'].downcase == 'pressão'
      parsed_value = parsed_data['questions'][0]['user_answers'][0]['text']
      parsed_value.gsub!(',','.').to_f
      request.pressure_proj = parsed_value

      parsed_value = parsed_data['questions'][1]['user_answers'][0]['text']
      parsed_value.gsub!(',','.').to_f
      request.pressure_opr = parsed_value
    end

    request.save
  end

  def parse_fluid_data data
    parsed_data = data['questions']
    parsed_array = []

    i = 2
    last_fluid = false
    while (parsed_data[i] and !last_fluid)

      current_answer = ''
      current_answer = parsed_data[i-2]['user_answers'][0]['text'] unless parsed_data[i-2]['user_answers'].empty?

      if not current_answer.in? ProposalsHelper::FLUIDS
        i += 3
        next
      end

      unless parsed_data[i-1]['user_answers'].empty?
        concentration_value = parsed_data[i-1]['user_answers'][0]['text']
        concentration_value.remove!(" %")

        current_answer += '/' + concentration_value.to_f.truncate.to_s
      end

      parsed_array << current_answer

      if !parsed_data[i]['user_answers'][0] or parsed_data[i]['user_answers'][0]['text'].downcase != 'sim'
        last_fluid = true
      end

      i += 3
    end

    return parsed_array
  end

  def print_values request
    puts "Repostas:"
    puts "Causa motivo: #{request.cause_or_reason}"
    puts "Preparação de superfície: #{request.surface_preparation}"
    puts "TAG: #{request.tag}"
    puts "Substrato: #{request.substratum}"
    puts "Soluções: #{request.solutions}"
    puts "fluido e concentração: #{request.fluids}"
    puts "Temperatura de projeto: #{request.temperature_proj}"
    puts "Temperatura de operacao: #{request.temperature_opr}"
    puts "Pressão Projeto: #{request.pressure_proj}"
    puts "Pressão operacao: #{request.pressure_opr}"
    puts "\n"
  end

  def fix_wrong_enterprise_on_reports
    reports = Report.all

    reports.each do |report|
      if report.enterprise_id and report.request.enterprise.id != report.enterprise_id
        report.enterprise_id = report.request.enterprise.id
        report.save
      end
    end
  end
end
