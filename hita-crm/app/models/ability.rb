class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= current_user

    if user.role?(User::ROLES[:admin])
      can :manage, :all
    else
      can :update, User
    end

    if user.role?(User::ROLES[:technician]) || user.role?(User::ROLES[:technical_manager]) || user.role?(User::ROLES[:commercial])
      can :index, Hindrance
      can :show_all, Event
      can :index, Requirement
      can :read, Enterprise, :user_id
      can :elaborate_proposals, Request
      can :upload, Stock
      can :new, Request
      can :edit, Request
      can :index, Request
      can :archive_request, Request
      can :see_request_values, Request
      can :update_request_values, Request
      can :manage, Enterprise
      can :update_request_enterprise, Request
      can :index_proposal, Form
      can :new_proposal_form, Form
      can :new_form, Form
      can :see_installments, RequestInstallment
      cannot :save_installments, RequestInstallment
      cannot :destroy, Enterprise

      if user.role?(User::ROLES[:commercial])
        can :read, Enterprise, :revenue
        can :index, Report
      end

      if user.role?(User::ROLES[:technical_manager])
        can :manage, Event
        cannot :read, Enterprise, :revenue
      end

      if user.role?(User::ROLES[:technician])
        cannot :read, Enterprise, :revenue
        cannot :index, Hindrance
        cannot :show_all, Event
        cannot :index, Requirement
      end
    end

    if user.role?(User::ROLES[:consultant])
      can :index, Requirement
      can :index, Report
      can :manage, Enterprise
      can :new, Request
      can :see_request_values, Request
      can :see_installments, RequestInstallment
      can :edit, Request
      cannot :update_request_enterprise, Request
      cannot :save_installments, RequestInstallment
      cannot :update_request_values, Request
      cannot :archive_request, Request
      cannot :destroy, Enterprise
      cannot :index_proposal, Form
      cannot :new_proposal_form, Form
      cannot :new_form, Form
    end

    if user.role?(User::ROLES[:regional_coordinator])
      can :show_all, Event
      can :index, Requirement
      can :index, Report
      can :new, Request
      can :manage, Enterprise
      can :archive_request, Request
      can :see_installments, RequestInstallment
      can :edit, Request
      cannot :save_installments, RequestInstallment
      cannot :destroy, Enterprise
      cannot :index_proposal, Form
      cannot :new_proposal_form, Form
      cannot :new_form, Form
    end

    if user.role?(User::ROLES[:service])
      can :update_request_step, Request
      can :upload, Stock
      cannot :see_installments, RequestInstallment
      cannot :archive_request, Request
      cannot :update_request_enterprise, Request
      cannot :see_request_values, Request
      cannot :update_request_values, Request
      cannot :index, Enterprise
      cannot :new, Request
      cannot :save_installments, RequestInstallment
    end

    if user.role?(User::ROLES[:financial])
      can :read, Enterprise, :user_id
      can :see_request_values, Request
      can :see_installments, RequestInstallment
      can :save_installments, RequestInstallment
      cannot :update_request_values, Request
      cannot :edit, Request
      cannot :read, Enterprise, :revenue
      cannot :update_request_enterprise, Request
      cannot :new, Request
      cannot :archive_request, Request
    end
  end
end
