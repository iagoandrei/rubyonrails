class Api::ProductsController < Api::ApiController
  def get_available_products

    if params[:datetime].present?
      begin
        datetime = DateTime.parse(params[:datetime])
      rescue ArgumentError
        return render json: { error: true, message: 'Ocorreu um erro ao identificar a data.', code: 500 }, status: :internal_server_error
      rescue
        return render json: { error: true, message: 'Ocorreu um erro ao identificar a data.', code: 500 }, status: :internal_server_error
      end

      @products = Product.where.not(name: ['Frete', 'Valor Serviço']).where('is_active = true AND updated_at >= ?', datetime).order(name: 'ASC')
    else
      @products = Product.where.not(name: ['Frete', 'Valor Serviço']).where(is_active: true).order(name: 'ASC')
    end
  end
end
