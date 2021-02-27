class Api::EnterprisesController < Api::ApiController

  def user_enterprises
    if params[:datetime].present?
      begin
        datetime = DateTime.parse(params[:datetime])
      rescue ArgumentError
        return render json: { error: true, message: 'Ocorreu um erro ao identificar a data.', code: 500 }, status: :internal_server_error
      rescue
        return render json: { error: true, message: 'Ocorreu um erro ao identificar a data.', code: 500 }, status: :internal_server_error
      end

      @enterprises = Enterprise.where('user_id = ? AND updated_at >= ?', current_user.id, datetime)
    else
      @enterprises = Enterprise.where('user_id = ?', current_user.id)
    end
  end

  def create
    enterprise = Enterprise.where(name: params[:enterprise][:name].upcase, cnpj: params[:enterprise][:cnpj]).last

    if enterprise
      return render json: {
        error: true,
        message: 'Já existe uma empresa com este nome e cnpj.',
        code: 400,
        enterprise: enterprise.as_json },
      status: :bad_request

    else
      enterprise      = Enterprise.new enterprise_params
      enterprise.name = enterprise.name.upcase
      enterprise.user = current_user

      if enterprise.save
        return render json: { message: 'Empresa salva com sucesso.', enterprise_id: enterprise.id }, status: :ok
      else
        return render json: { error: true, message: 'Ocorreu um erro ao salvar a empresa.', code: 500 }, status: :internal_server_error
      end
    end
  end

private

  def enterprise_params
    params.require(:enterprise).permit(:name, :industry_sector, :enterprise_type, :cnpj, :price_table,
                                       :cep, :city, :state, :address, :business_name)
  end
end
