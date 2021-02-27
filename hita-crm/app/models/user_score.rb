class UserScore < ApplicationRecord
  belongs_to :requirement
  belongs_to :user

  has_one_attached :file
  belongs_to :responsible, class_name: 'User', foreign_key: 'responsible_id', optional: true
  belongs_to :request, optional: true
  belongs_to :request_proposal, optional: true
end
