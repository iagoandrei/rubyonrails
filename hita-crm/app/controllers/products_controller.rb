class ProductsController < ApplicationController
  require 'rubygems' #Verificar
  require 'zip'

  def index
    @title = "Hita CRM | Gerenciar Produtos"
    @products_json = []
    @dollar = "R$ " + Product.last.current_dollar_price.to_s

    products = Product.where.not(name: ['Frete', 'Valor Serviço']).where(is_active: true).order(name: 'ASC')
    products.each do |product|
      @products_json << build_product_object(product)
    end

    @products_json = @products_json.as_json
  end

  def allproducts
    product = Product.all
    respond_to do |format|  ## Add this
      format.json { render json: product, status: :ok}
      format.html 
      ## Other format
    end      
  end

  def update
    @product = Product.find_by_id params[:id]

    respond_to do |format|
      if @product.update(product_params)        
        format.json { render :show, status: :ok, location: @request_condition }
      else        
        format.json { render json: @request_condition.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @product = Product.new(product_params)
    @product.save!

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Request condition was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end

  end

  def product_params
    params.require(:product).permit(:name, :category,
      :product_type, :dollar_price, :current_dollar_price,
      :yara_price, :fob_price, :braskem_price, :braskem_sp_price, 
      :mosaic_price, :vale_mining_price, :anglo_american_price ,:arcelor_price,
      :modec_price, :petrobras_price, :code, :unit, :ipi, :income, :characteristics,
      :ncm)
  end
    
  def update_product
    product = Product.find_by_id params[:item][:id]
    raise ActiveRecord::RecordNotFound if product.nil?

    dollar_dependent_value       = convert_br_currency_to_float(params[:item]['Valor em Dólar']) * product.current_dollar_price

    product.dollar_price         = convert_br_currency_to_float(params[:item]['Valor em Dólar'])
    product.fob_price            = dollar_dependent_value.ceil

    if params[:item]['Vale Fertilizante (Yara)  Tabela/(1-0,0725)'] == 'R$ 0,00'
      params[:item]['Vale Fertilizante (Yara)  Tabela/(1-0,0725)'] = ''
    end

    begin
      yara_expression = params[:item]['Vale Fertilizante (Yara)  Tabela/(1-0,0725)'].gsub('dolar', product.dollar_price.to_s)
    rescue SyntaxError
      params[:item]['Vale Fertilizante (Yara)  Tabela/(1-0,0725)'] = ''
    rescue
      params[:item]['Vale Fertilizante (Yara)  Tabela/(1-0,0725)'] = ''
    end

    yara_item = params[:item]['Vale Fertilizante (Yara)  Tabela/(1-0,0725)']

    if yara_item == '-' or yara_item == '' or yara_item.squeeze(' ') == ' '
      product.yara_price = nil
    else
      product.yara_price = yara_item
    end

    product.braskem_price        = save_table_value(params[:item]['Braskem BA, RS, AL'])
    product.braskem_sp_price     = save_table_value(params[:item]['Braskem SP'])
    product.mosaic_price         = save_table_value(params[:item]['Mosaic'])
    product.vale_mining_price    = save_table_value(params[:item]['Vale Mineração'])
    product.anglo_american_price = save_table_value(params[:item]['Anglo American'])
    product.arcelor_price        = save_table_value(params[:item]['Arcelor'])
    product.modec_price          = save_table_value(params[:item]['Modec'])
    product.petrobras_price      = save_table_value(params[:item]['Petrobrás'])

    if product.save
      object = build_product_object product
      render json: object, status: :ok
    else
      render json: {}, status: :internal_server_error
    end
  end

  def save_table_value value
    return nil if value == '-' or value == '' or value.squeeze(' ') == ' '
    return convert_br_currency_to_float(value).ceil
  end

  def calculate_table_value value
    return '-' if value.nil?
    return number_to_currency(value)
  end

  def build_product_object product
    object = {
      'id': product.id,
      'Produto': product.name ? product.name : '',
      'Valor em Dólar': number_to_currency(product.dollar_price, :unit => 'US$'),
      'Geral FOB': number_to_currency(product.fob_price) ? number_to_currency(product.fob_price) : number_to_currency(0),
      'Braskem BA, RS, AL': calculate_table_value(product.braskem_price),
      'Braskem SP': calculate_table_value(product.braskem_sp_price),
      'Vale Fertilizante (Yara)  Tabela/(1-0,0725)': product.calculate_yara_value ? number_to_currency(product.calculate_yara_value) : '-',
      'Mosaic': calculate_table_value(product.mosaic_price),
      'Vale Mineração': calculate_table_value(product.vale_mining_price),
      'Anglo American': calculate_table_value(product.anglo_american_price),
      'Arcelor': calculate_table_value(product.arcelor_price),
      'Modec': calculate_table_value(product.modec_price),
      'Petrobrás': calculate_table_value(product.petrobras_price)
    }

    return object
  end
  

  def update_dollar_value
    dollar = convert_br_currency_to_float(params[:dollar_value])
    Product.update(current_dollar_price: dollar)
    Product.update_all('fob_price = ceil(dollar_price * current_dollar_price)')
    redirect_to products_index_url
  end

  def check_product_price
    enterprise = Enterprise.find_by id: params[:enterprise_id]
    product = Product.find_by code: params[:product_code]

    render json: { price: product.get_product_price(enterprise.price_table).to_f }
  end
end
