class EquipmentsController < ApplicationController

  def index
    @title = "Hita CRM | Equipamentos"
    @equipments = Equipment.all.order(name: 'ASC')
  end

  def new
    @title = "Hita CRM | Criar Equipamento"
  end

  def create
    equipment = Equipment.new equipment_params
    equipment.is_for_product = params[:equipment][:is_for_product] == 'on'
    equipment.is_for_service = params[:equipment][:is_for_service] == 'on'

    if equipment.save
      flash[:notice] = 'O equipamento foi adicionado com sucesso'
    else
      flash[:alert] = 'Ocorreu um erro ao adicionar o equipamento'
    end

    redirect_to equipments_index_url
  end

  def edit
    @equipment = Equipment.find_by id: params[:id]
    @title = "Hita CRM | Editar equipamento: #{@equipment.name}" unless @equipment.nil?

    raise ActiveRecord::RecordNotFound if @equipment.nil?
  end

  def update
    equipment = Equipment.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if equipment.nil?

    equipment.is_for_product = params[:equipment][:is_for_product] == 'on'
    equipment.is_for_service = params[:equipment][:is_for_service] == 'on'

    if equipment.update equipment_params
      flash[:notice] = 'O equipamento foi atualizado com sucesso'
    else
      flash[:alert] = 'Ocorreu um erro ao atualizar o equipamento'
    end

    redirect_to equipments_index_url
  end

  def remove_image
    blob = ActiveStorage::Attachment.find_by_id params[:blob_id]

    if blob.purge
      flash[:notice] = 'Imagem do equipamento removida'
    else
      flash[:alert] = 'Ocorreu um erro ao remover a image'
    end

    redirect_to edit_equipment_url(blob.record.id)
  end

  def destroy
    equipment = Equipment.find_by id: params[:id]

    if equipment&.destroy
      flash[:notice] = 'O equipamento foi removido com sucesso'
    else
      flash[:alert] = 'Ocorreu um erro ao remover o equipamento'
    end

    redirect_to equipments_index_url
  end

  def manage_quizzes
    @title = "Hita CRM | Gerenciar Questionários"
    @equipments = Equipment.all.order(name: 'ASC')
    @questions = RequestQuiz.all.order(position: 'ASC')
  end

  def update_question
    equipments = Equipment.where(id: params[:equipments_ids])

    if params[:value] == 'true'
      equipments.each do |equipment|
        equipment.add_question(params[:question_id].to_i)
      end
    else
      equipments.each do |equipment|
        equipment.remove_question(params[:question_id].to_i)
      end
    end

    head :ok
  end

  def get_equipment_infos
    equipment = Equipment.find_by id: params[:id]
    return render json: {}, status: 404 if equipment.nil?

    equipment_json = {}
    equipment_json['equipment_id'] = equipment.id
    equipment_json['number_of_inputs'] = equipment.number_of_inputs
    equipment_json['image_1'] = equipment.image_1.attached? ? rails_blob_path(equipment.image_1) : ''
    equipment_json['image_2'] = equipment.image_2.attached? ? rails_blob_path(equipment.image_2) : ''
    equipment_json['image_3'] = equipment.image_3.attached? ? rails_blob_path(equipment.image_3) : ''

    render json: equipment_json
  end

private
  def equipment_params
    params.require(:equipment).permit(:name, :number_of_inputs, :image_1, :image_2, :image_3)
  end
end
