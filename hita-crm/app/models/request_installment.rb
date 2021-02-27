class RequestInstallment < ApplicationRecord
  belongs_to :request
  has_many :reports, dependent: :destroy
end
