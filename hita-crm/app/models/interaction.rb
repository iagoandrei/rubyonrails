class Interaction < ApplicationRecord
  belongs_to :collaborator, optional: true
  belongs_to :enterprise, optional: true
  belongs_to :user, optional: true
  belongs_to :old_enterprise, class_name: 'Enterprise', foreign_key: 'enterprise_changed_old', optional: true
  belongs_to :new_enterprise, class_name: 'Enterprise', foreign_key: 'enterprise_changed_new', optional: true
  belongs_to :owner, :class_name => 'User', optional: true
  belongs_to :request, optional: true
  belongs_to :event, optional: true

  has_many_attached :files

  def print_interaction
    if [:training, :seminar, :meeting, :visit, :other].include? self.interaction_type.to_sym
      print_action
    elsif self.interaction_type == 'comment'
      print_conversation
    elsif self.interaction_type == 'collaborator_enterprise_changed'
      print_collaborator_enterprise_changed
    elsif [:in_line, :elaboration, :allocated, :approval, :revenue, :mobilization, :payment, :execution, :aftersale, :finished].include? self.interaction_type.to_sym
      print_request_step_update
    elsif self.interaction_type == 'event'
      print_event_enterprise
    elsif self.interaction_type == 'proposal_approved'
      print_proposal_approved
    elsif self.interaction_type == 'proposal_removed'
      print_proposal_removed
    elsif self.interaction_type == 'installment_removed'
      print_installment_removed
    elsif self.interaction_type == 'requested_by'
      print_requested_by
    elsif self.interaction_type == 'validated_premises'
      print_validated_premises
    end
  end

private

  def print_action
    ApplicationController.render(partial: 'shared/interaction_action', :locals => { :interaction => self })
  end

  def print_conversation
    ApplicationController.render(partial: 'shared/interaction_conversation', :locals => { :interaction => self })
  end

  def print_collaborator_enterprise_changed
    ApplicationController.render(partial: 'shared/collaborator_enterprise_changed', :locals => { :interaction => self })
  end

  def print_request_step_update
    ApplicationController.render(partial: 'shared/request_step_updated', :locals => { :interaction => self })
  end

  def print_event_enterprise
    ApplicationController.render(partial: 'shared/print_event_enterprise', :locals => { :interaction => self })
  end

  def print_proposal_approved
    ApplicationController.render(partial: 'shared/interaction_proposal_approved', :locals => { :interaction => self })
  end

  def print_proposal_removed
    ApplicationController.render(partial: 'shared/interaction_proposal_removed', :locals => { :interaction => self })
  end

  def print_installment_removed
    ApplicationController.render(partial: 'shared/interaction_installment_removed', :locals => { :interaction => self })
  end

  def print_requested_by
    ApplicationController.render(partial: 'shared/interaction_requested_by', :locals => { :interaction => self })
  end

  def print_validated_premises
    ApplicationController.render(partial: 'shared/interaction_validated_premises', :locals => { :interaction => self })
  end
end
