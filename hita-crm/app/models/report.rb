class Report < ApplicationRecord
  belongs_to :enterprise, optional: true
  belongs_to :product, optional: true
  belongs_to :user, optional: true
  belongs_to :request, optional: true
  belongs_to :request_installment, optional: true
end
