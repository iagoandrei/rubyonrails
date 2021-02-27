class Notification < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :collaborator, optional: true
  belongs_to :enterprise, optional: true
  belongs_to :interaction, optional: true
  belongs_to :event, optional: true
  belongs_to :request, optional: true
  belongs_to :hindrance, optional: true
  belongs_to :notifier, :class_name => 'User', optional: true
end
