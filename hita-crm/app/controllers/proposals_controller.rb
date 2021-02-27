class ProposalsController < ApplicationController
  skip_before_action :verify_authenticity_token #check this

  def index
  end

  def create
    proposal = Proposal.last
    proposal.files = params[:files]

    if proposal.save
      head 200
    else
      head 500
    end
  end

  def get_proposal_files
    proposal = Proposal.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if proposal.nil?

    files = []
    proposal.files.each do |file|
      blob = {}
      blob['name'] = file.filename
      blob['type'] = file.content_type
      blob['data'] = url_for(file.blob)
      files << blob
    end

    render json: files
  end

private
  def proposal_params
    params.require(:proposal).permit(:name, :files)
  end
end
