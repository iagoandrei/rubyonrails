class StocksController < ApplicationController
  def index
    @title = 'Hita CRM | Estoque'
    @materials = Stock.find_by_filename "materials"
    @products  = Stock.find_by_filename "products"
    @labor    = Stock.find_by_filename "labor"
  end

  def new
    @title = 'Hita CRM | Atualizar Estoque'
    @materials = Stock.find_by_filename "materials"
    @products  = Stock.find_by_filename "products"
    @labor    = Stock.find_by_filename "labor"
  end

  def upload
    stock = Stock.find_by_filename params[:stock][:filename]

    if stock
      stock.file.purge
      stock.file.attach params[:stock][:file]
    else
      stock = Stock.new stock_params
    end

    if stock.save
      flash[:notice] = "Arquivo enviado com sucesso!"
    else
      flash[:alert] = "Ocorreu um erro inesperado! Tente novamente."
    end

    redirect_to stocks_new_path
  end

  def request_product_table
    require 'net/http'
    require 'uri'

    if params[:product_type].present? and params[:product_type] == 'reserved'
      url = 'http://mssql-api/api/get_available_products/reserved'
    else
      url = 'http://mssql-api/api/get_available_products'
    end

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, 5656)
    res = http.get(uri.path, headers)
    return render json: res.body.as_json
  end

  def check_product_by_code
    require 'net/http'
    require 'uri'

    uri = URI.parse('http://mssql-api/api/products_by_code/' + params[:code])
    http = Net::HTTP.new(uri.host, 5656)
    res = http.get(uri.path, headers)
    return render json: res.body.as_json
  end

private
  def stock_params
    params.require(:stock).permit(:filename, :file)
  end
end
