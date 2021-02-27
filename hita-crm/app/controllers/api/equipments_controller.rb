class Api::EquipmentsController < Api::ApiController

  def get_equipment_infos
    begin
      datetime = DateTime.parse(params[:datetime])
    rescue ArgumentError
      return render json: { error: true, message: 'Ocorreu um erro ao identificar a data.', code: 500 }, status: :internal_server_error
    rescue
      return render json: { error: true, message: 'Ocorreu um erro ao identificar a data.', code: 500 }, status: :internal_server_error
    end

    @equipments = Equipment.where('updated_at >= ?', datetime)
  end
end
