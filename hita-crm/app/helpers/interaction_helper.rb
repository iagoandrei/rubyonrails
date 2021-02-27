module InteractionHelper

  INTERACTION = {
    training: 'Treinamento',
    seminar: 'Seminário e Treinamentos',
    meeting: 'Reunião',
    visit: 'Visita',
    comment: 'Comentário',
    in_line: 'Em Fila',
    allocated: 'Técnico Alocado',
    elaboration: 'Elaboração',
    approval: 'Aprovação',
    revenue: 'Faturamento',
    mobilization: 'Mobilização',
    payment: 'Pagamento',
    execution: 'Execução',
    aftersale: 'Pós-venda',
    finished: 'Finalização',
    event: 'Evento',
    proposal_approved: 'Proposta Enviada Aprovada',
    collaborator_enterprise_changed: 'Mudou de empresa',
    proposal_removed: 'Proposta Enviada Apagada',
    installment_removed: 'Parcela cancelada',
    requested_by: 'Oportunidade criada por',
    validated_premises: 'Premissas de Proposta Validadas'
  }

  def self.create(interaction_type, params = {})
    owner                        = User.find_by_id params[:owner_id]
    interaction                  = Interaction.new
    interaction.interaction_type = interaction_type
    interaction.content          = params[:content] if params[:content]
    interaction.owner            = owner

    if params[:interaction_attachment]
      params[:interaction_attachment].each do |attachment|
        interaction.files.attach attachment
      end
    end

    case params[:current]
    when 'enterprise'
      enterprise             = Enterprise.find_by_id params[:enterprise_id]
      interaction.enterprise = enterprise
      interaction.interaction_date = Date.parse(params[:interaction_date]) if params[:interaction_date].present?

      if params[:collaborator_id]
        collaborator = Collaborator.find_by_id params[:collaborator_id]
        interaction.collaborator = collaborator
      end

      if params[:mentioned_users_id]
        params[:mentioned_users_id].each do |id|
          mentioned_user           = User.find_by_id id
          notification             = Notification.new

          notification.user        = mentioned_user
          notification.message     = params[:content]
          notification.interaction = interaction
          notification.enterprise  = enterprise
          notification.save
        end
      end

      if params[:event_id]
        event             = Event.find_by_id params[:event_id]
        interaction.event = event
      end
    when 'collaborator'
      collaborator             = Collaborator.find_by_id params[:collaborator_id]
      interaction.collaborator = collaborator

      if params[:mentioned_users_id]
        params[:mentioned_users_id].each do |id|
          mentioned_user           = User.find_by_id id
          notification             = Notification.new

          notification.user         = mentioned_user
          notification.message      = params[:content]
          notification.interaction  = interaction
          notification.collaborator = collaborator
          notification.save
        end
      end
    when 'request'
      request             = Request.find_by_id params[:request_id]
      interaction.request = request
      interaction.request_type = params[:request_type]
    end

    if interaction_type == 'collaborator_enterprise_changed'
      interaction.enterprise_changed_old = params[:old_enteprise_id]
      interaction.enterprise_changed_new = params[:new_enteprise_id]
      interaction.collaborator = Collaborator.find_by_id params[:collaborator_id]
    end

    interaction.save
  end
end
