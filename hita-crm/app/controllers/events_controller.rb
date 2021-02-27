class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [ :finalize ]

  def index
    @event_id = params[:event_id] if params[:event_id].present?
    @events   = ['Treinamento', 'Seminário', 'Reunião', 'Visita', 'Outro']
  end

  def show_all
    @events   = ['Treinamento', 'Seminário', 'Reunião', 'Visita', 'Outro']
  end

  def update
    event                       = Event.find_by_id params[:event][:id]
    event.is_all_day            = true if params[:event][:is_all_day].present?
    event.street                = params[:event][:street]
    event.event_type            = params[:event][:event_type].present? ? params[:event][:event_type] : 'other'
    event.enterprise            = nil
    event.has_consultant        = false
    event.has_technician        = false
    event.has_technical_manager = false
    event.start_date            = params[:event][:date] + ' ' + params[:event][:start_hour]
    event.end_date              = params[:event][:date] + ' ' + params[:event][:end_hour]

    if params[:event][:enterprise_id].present? and params[:event_autocomplete].present?
      enterprise       = Enterprise.find_by_id params[:event][:enterprise_id]
      event.enterprise = enterprise
    end

    event.users = []
    user_ids    = params[:user_ids].map(&:to_i)

    if params[:consultant].present?
      event.has_consultant = true

      consultants = User.where(role: User::ROLES[:consultant], is_active: true)

      consultants.each do |consultant|
        user_ids << consultant.id if user_ids.exclude? consultant.id
      end
    end

    if params[:technician].present?
      event.has_technician = true

      technicians = User.where(role: User::ROLES[:technician], is_active: true)

      technicians.each do |technician|
        user_ids << technician.id if user_ids.exclude? technician.id
      end
    end

    if params[:technical_manager].present?
      event.has_technical_manager = true

      technical_managers = User.where(role: User::ROLES[:technical_manager], is_active: true)

      technical_managers.each do |technical_manager|
        user_ids << technical_manager.id if user_ids.exclude? technical_manager.id
      end
    end

    user_ids.each do |id|
      user         = User.find_by_id id
      event.users << user
    end

    event.update_attributes(event_params)

    if event.save
      Notification.where(event_id: event.id).destroy_all

      user_ids.each do |id|
        user                 = User.find_by_id id
        notification         = Notification.new
        notification.event   = event
        notification.user    = user
        notification.message = "<span class='blue-light-color'>#{event.title}</span>, #{l(event.start_date, format: :extended_version_2).downcase}."

        if event.owner_id != id.to_i
          notification.title   = "#{event.owner.name} adicionou você a um evento."
        else
          notification.title   = "Você tem um novo evento."
        end

        notification.save

        if event.start_date.to_date > Date.today
          dates = [event.start_date.to_date - 1, event.start_date.to_date]

          dates.each do |date|
            notification               = Notification.new
            notification.event         = event
            notification.user          = user
            notification.schedule_date = date

            if date == event.start_date.to_date
              notification.title   = "Você tem um evento hoje."
              notification.message = "<span class='blue-light-color'>#{event.title}</span>, hoje às #{event.start_date.strftime("%H:%M")}."
            else
              notification.title   = "Seu evento acontecerá amanhã."
              notification.message = "<span class='blue-light-color'>#{event.title}</span>, amanhã às #{event.start_date.strftime("%H:%M")}."
            end

            notification.save
          end
        end
      end

      flash[:notice] = "Atividade atualizado com sucesso!"
    else
      flash[:alert] = "Não foi possível atualizar a atividade. Favor tentar novamente."
    end

    redirect_to events_index_path
  end

  def create
    dates      = params[:event][:dates]
    start_hour = params[:event][:start_hour]
    end_hour   = params[:event][:end_hour]

    begin
      event_token = SecureRandom.alphanumeric
    end while Event.find_by event_token: event_token

    dates.each_with_index do |date, i|
      event = Event.new event_params
      event.event_token = event_token

      if start_hour[i] and end_hour[i]
        event.start_date = Time.zone.parse(date + " " + start_hour[i])
        event.end_date = Time.zone.parse(date + " " + end_hour[i])
      else
        event.start_date = date
        event.end_date   = date
      end

      event.is_all_day = true if params[:event][:is_all_day].present?
      event.street     = params[:event][:street]
      event.event_type = params[:event][:event_type].present? ? params[:event][:event_type] : 'other'

      if params[:event][:enterprise_id].present?
        enterprise       = Enterprise.find_by_id params[:event][:enterprise_id]
        event.enterprise = enterprise
      end

      event.owner = current_user
      user_ids    = params[:user_ids].map(&:to_i)

      if params[:consultant].present?
        event.has_consultant = true

        if current_user.role?(User::ROLES[:regional_coordinator])
          consultants = User.where(team: current_user.team, is_active: true)
        else
          consultants = User.where(role: User::ROLES[:consultant], is_active: true)
        end

        consultants.each do |consultant|
          user_ids << consultant.id if user_ids.exclude? consultant.id
        end
      end

      if params[:technician].present?
        event.has_technician = true

        technicians = User.where(role: User::ROLES[:technician], is_active: true)

        technicians.each do |technician|
          user_ids << technician.id if user_ids.exclude? technician.id
        end
      end

      if params[:technical_manager].present?
        event.has_technical_manager = true

        technical_managers = User.where(role: User::ROLES[:technical_manager], is_active: true)

        technical_managers.each do |technical_manager|
          user_ids << technical_manager.id if user_ids.exclude? technical_manager.id
        end
      end

      user_ids.each do |id|
        user = User.find_by_id id
        event.users << user
      end

      if event.save
        user_ids.each do |id|
          user                 = User.find_by_id id
          notification         = Notification.new
          notification.event   = event
          notification.user    = user
          notification.message = "<span class='blue-light-color'>#{event.title}</span>, #{l(event.start_date, format: :extended_version_2).downcase}."

          if event.owner_id != id.to_i
            notification.title   = "#{event.owner.name} adicionou você a um evento."
          else
            notification.title   = "Você tem um novo evento."
          end

          notification.save

          if event.start_date.to_date > Date.today
            dates = [event.start_date.to_date - 1, event.start_date.to_date]

            dates.each do |date|
              notification               = Notification.new
              notification.event         = event
              notification.user          = user
              notification.schedule_date = date

              if date == event.start_date.to_date
                notification.title   = "Você tem um evento hoje."
                notification.message = "<span class='blue-light-color'>#{event.title}</span>, hoje às #{event.start_date.strftime("%H:%M")}."
              else
                notification.title   = "Seu evento acontecerá amanhã."
                notification.message = "<span class='blue-light-color'>#{event.title}</span>, amanhã às #{event.start_date.strftime("%H:%M")}."
              end

              notification.save
            end
          end
        end

        if params[:event][:enterprise_id].present?
          interaction_params = {
            current: 'enterprise',
            enterprise_id: event.enterprise.id,
            owner_id: current_user.id,
            event_id: event.id
          }

          InteractionHelper.create 'event', interaction_params
        end

        if event.event_type == 'Visita'
          requirement_title = 'Contatos com Clientes'

          user_score_params = {
            requirement_title: requirement_title,
            current_user_id: current_user.id,
            current_date: Date.today
          }

          UserScoresHelper.create user_score_params
        elsif event.event_type == 'Seminário'
          requirement_title = 'Seminários ou Treinamentos'

          user_score_params = {
            requirement_title: requirement_title,
            current_user_id: current_user.id,
            current_date: Date.today
          }

          UserScoresHelper.create user_score_params
        end

        flash[:notice] = "Atividade criada com sucesso!"
      else
        flash[:alert] = "Não foi possível criar a atividade. Favor tentar novamente."
      end
    end

    redirect_to events_index_path
  end

  def get_event_infos
    event = Event.find_by id: params[:id]

    raise ActiveRecord::RecordNotFound if event.nil?

    event_json                    = event.as_json
    event_json['enterprise_name'] = event.enterprise&.name
    event_json['date']            = event.start_date.strftime("%d/%m/%Y")
    event_json['start_hour']      = event.start_date.strftime("%H:%M")
    event_json['end_hour']        = event.end_date.strftime("%H:%M")
    event_json['is_all_day']      = event.is_all_day ? true : false
    event_json['street']          = event.street
    event_json['user_ids']        = event.users.pluck(:id)

    render json: event_json
  end

  def render_events
    if params[:event_id].present?
      @events = current_user.events.where(id: params[:event_id], status: Event::STATUS[:active]).order('start_date asc').paginate(:page => params[:page], :per_page => 1)
    else
      @events = Event.joins(:users).where('users.id IN (?)', params[:id]).where(status: Event::STATUS[:active]).order('start_date asc').paginate(:page => params[:page], :per_page => 20)
    end

    @events       = @events.where(start_date: Date.parse(params[:startDate]).to_date.beginning_of_day..Date.parse(params[:endDate]).to_date.end_of_day) if params[:startDate].present? and params[:endDate].present?
    @events_pages = @events
    @events       = @events.uniq.group_by { |event| event.start_date.to_date}
    @current_page = params[:page]
    @events       = @events.uniq
  end

  def render_events_calendar
    @events = []

    if params[:id].present?
      params[:id] = [params[:id]] if params[:id].size == 1

      params[:id].each do |id|
        user = User.find_by_id id

        if params[:event_id].present?
          Event.joins(:users).where('users.id = ?', id).where(id: params[:event_id]).each_with_index do |event, index|
            events_json                    = {}
            events_json['id']              = event.id
            events_json['title']           = event.title
            events_json['start']           = event.start_date.strftime('%Y-%m-%d')
            events_json['backgroundColor'] = user.get_color
            events_json['borderColor']     = user.get_color

            @events << events_json
          end
        else
          Event.joins(:users).where('users.id = ?', id).each_with_index do |event, index|
            events_json                    = {}
            events_json['id']              = event.id
            events_json['title']           = event.title
            events_json['start']           = event.start_date.strftime('%Y-%m-%d')
            events_json['backgroundColor'] = user.get_color
            events_json['borderColor']     = user.get_color

            @events << events_json
          end
        end
      end
    end
  end

  def finalize
    current_event = Event.find_by_id params[:id]

    if current_event.event_token.nil?
      if current_event.update_attribute(:status, Event::STATUS[:finished])
        flash[:notice] = "Sua atividade foi concluída com sucesso!"

        return head 200
      else
        flash[:alert] = "Erro ao concluir atividade. Favor tentar novamente"

        return head 500
      end
    end

    events = Event.where(event_token: current_event.event_token)

    if events.update(status: Event::STATUS[:finished])
      flash[:notice] = "Sua atividade foi concluída com sucesso!"

      return head 200
    else
      flash[:alert] = "Erro ao concluir atividade. Favor tentar novamente"

      return head 500
    end
  end

  def destroy
    current_event = Event.find_by_id params[:id]

    if current_event.event_token.nil?
      if current_event.destroy
        flash[:notice] = "Atividade removida com sucesso"
      else
        flash[:alert] = "Não foi possível remover a atividade. Favor tentar novamente"
      end

      return redirect_to events_index_path
    end

    events = Event.where(event_token: current_event.event_token)

    if events.destroy_all
      flash[:notice] = "Atividades removidas com sucesso"
    else
      flash[:alert] = "Não foi possível remover as atividades. Favor tentar novamente"
    end

    redirect_to events_index_path
  end

private
  def event_params
    params.require(:event).permit(:title)
  end
end
