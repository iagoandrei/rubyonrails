class RequestProposal < ApplicationRecord
  belongs_to :request
  has_one_attached :file, dependent: :destroy
  has_one :user_score

  STATUS = {
  	approved: 'Aprovada',
  	refused: 'Recusada',
  	not_evaluated: 'Não Avaliada'
  }.freeze

  serialize :feedback_reasons, Array
end
