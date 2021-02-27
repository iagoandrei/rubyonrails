class Requirement < ApplicationRecord
  has_many :user_scores

  REQUIREMENT_TYPE = {
    sales: 'Vendas',
    strategy: 'Estratégia',
    technical_information: 'Informação Técnica',
    communication: 'Comunicação',
    empowerment: 'Capacitação'
  }
end
