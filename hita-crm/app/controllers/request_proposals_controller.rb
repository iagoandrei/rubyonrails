class RequestProposalsController < ApplicationController
  def get_request_proposals
    request = Request.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request.nil?

    files_json = []
    request.request_proposals.each do |proposal|
      current_blob = {}
      if proposal.file.attached?
        current_blob['filename'] = proposal.file.blob.filename
        current_blob['date'] = proposal.file.blob.created_at.strftime("%d/%m/%y %H:%M")
        current_blob['size'] = number_to_human_size(proposal.file.blob.byte_size)
        current_blob['blob_path'] = rails_blob_path(proposal.file.blob, disposition: "attachment")
      else
        current_blob['filename'] = '(Nenhuma proposta anexada)'
        current_blob['date'] = '--/--/-- --:--'
        current_blob['size'] = '0 KB'
        current_blob['blob_path'] = 'none'
      end

      current_blob['id'] = proposal.id
      current_blob['proposal_id'] = proposal.id
      current_blob['situation'] = RequestProposal::STATUS[proposal.status.to_sym]
      current_blob['feedback_description'] = proposal.feedback_description
      current_blob['feedback_reasons'] = proposal.feedback_reasons
      files_json << current_blob
    end

    render json: files_json.as_json, status: :ok
  end

  def request_proposal_feedback
    proposal = RequestProposal.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if proposal.nil?

    request = proposal.request
    time_diff = ((Time.now - proposal.created_at)/3600).round

    if request.high_urgency and time_diff >= 72
      user_score_params = {
        requirement_title: 'Priorização de propostas',
        score_type: 'Penalidade',
        current_user_id: current_user.id,
        current_date: Date.today
      }

      UserScoresHelper.create user_score_params

      request.high_urgency = false
      request.save
    end

    if params[:status] == 'refused'
      proposal.status = 'refused'
      proposal.feedback_description = params[:reason_description]
      proposal.feedback_reasons = params[:reasons]

      request.is_active = false

      if request.save
        request.hindrances.destroy_all
      else
        return render json: { message: 'Erro ao arquivar pedido. '}, status: :internal_server_error
      end

      if current_user.role?(User::ROLES[:consultant]) and proposal.user_score.nil? and (!proposal.feedback_reasons.empty? or !proposal.feedback_description.blank?)
        user_score_params = {
          requirement_title: 'Feedback de propostas recusadas',
          current_user_id: current_user.id,
          current_date: Date.today,
          request_proposal_id: proposal.id
        }

        UserScoresHelper.create user_score_params
      end
    else
      proposal.status = 'approved'
    end

    if proposal.save
      render json: {}, status: :ok
    else
      render json: { message: 'Erro ao salvar proposta. '}, status: :internal_server_error
    end
  end

  def create_fake_request_proposal
    request = Request.find_by! id: params[:request_id]
    return head :ok if request.request_proposals.present?

    proposal = RequestProposal.new
    proposal.request = request

    if proposal.save
      head :ok
    else
      head :internal_server_error
    end
  end

  def remove_request_proposal
    request_proposal = RequestProposal.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request_proposal.nil?

    request = request_proposal.request
    filename = request_proposal.file.blob.filename

    if request_proposal.destroy

     interaction_params = {
        current: 'request',
        content: "A proposta '<span class='weight-500'>#{filename}</span>' foi apagada.",
        owner_id: current_user.id,
        request_type: request.request_type,
        request_id: request.id
      }
      InteractionHelper.create 'proposal_removed', interaction_params

      head :ok
    else
      head :internal_server_error
    end
  end
end
