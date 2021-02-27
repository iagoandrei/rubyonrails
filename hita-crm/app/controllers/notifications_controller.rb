class NotificationsController < ApplicationController
  def redirect
    notification = Notification.find_by_id params[:id]
    @error_title = nil

    if notification.interaction and notification.enterprise.nil?
      @error_title = 'O contato desta notificação não foi encontrado.'
      @text = 'Isso ocorre quando o contato não existe ou foi removido.'

      notification.update_attribute(:read, true)

      if notification.collaborator.nil?
        return render 'notification_error'
      end

      redirect_to collaborators_index_path(:collaborator_id => notification.collaborator.id)
    elsif notification.interaction and notification.enterprise
      @error_title = 'A empresa desta notificação não foi encontrada.'
      @text = 'Isso ocorre quando a empresa não existe ou foi removida.'

      notification.update_attribute(:read, true)

      if notification.enterprise.nil?
        return render 'notification_error'
      end

      redirect_to enterprises_index_path(:enterprise_id => notification.enterprise.id)
    elsif notification.event
      @error_title = 'O evento desta notificação não foi encontrado.'
      @text = 'Isso ocorre quando o evento não existe ou foi removido.'

      notification.update_attribute(:read, true)

      if notification.event.nil?
        return render 'notification_error'
      end

      redirect_to events_index_path(:event_id => notification.event.id)
    elsif notification.request
      @error_title = 'O impedimento ou o pedido desta notificação não foi encontrado.'
      @text = 'Isso ocorre quando o impedimento foi removido, trocado ou não existe.'

      notification.update_attribute(:read, true)

      if notification.hindrance.nil? or notification.hindrance.request.nil?
        return render 'notification_error'
      end

      redirect_to hindrance_index_path(:request_id => notification.hindrance.request.id)
    end
  end

  def render_current_notifications
    content = ''

    current_user.notifications.where(read: false).order('created_at DESC').each do |notification|
      if notification.interaction
        content += render_to_string(:partial => 'notifications/interaction_notification', :locals => {:notification => notification, :current_user => current_user})
      elsif notification.event
        if notification.event.start_date >= Date.today
          if notification.schedule_date.nil? or notification.schedule_date == Date.today
            content += render_to_string(:partial => 'notifications/event_notification', :locals => {:notification => notification, :current_user => current_user})
          end
        end
      elsif notification.request
        content += render_to_string(:partial => 'notifications/request_notification', :locals => {:notification => notification, :current_user => current_user})
      end
    end

    render html: content.html_safe
  end
end
