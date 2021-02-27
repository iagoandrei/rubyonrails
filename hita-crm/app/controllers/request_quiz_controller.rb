class RequestQuizController < ApplicationController
  def index
    @title = "Hita CRM | Perguntas"
    @quizzes = RequestQuiz.all.order(title: 'ASC')
  end

  def new
    @title = "Hita CRM | Novo Bloco de Perguntas"
  end

  def create
    request_quiz = RequestQuiz.new
    request_quiz.title = params[:title]
    request_quiz.data = params[:data]

    user = User.find_by id: params[:user_id]
    raise ActiveRecord::RecordNotFound if user.nil?

    cycles = search_cycles params[:data]

    if cycles.length > 0
      flash[:alert] = "Não podem ocorrer ciclos nas perguntas. Verifique os ciclos entre as seguintes perguntas: #{cycles}"
      return redirect_to edit_request_quiz_url(request_quiz.id)
    end

    request_quiz.user = user
    request_quiz.save

    if request_quiz.save
      flash[:notice] = 'O bloco foi criado com sucesso'
    else
      flash[:alert] = 'Ocorreu um erro ao criar o bloco'
    end

    redirect_to request_quiz_index_url
  end

  def edit
    request_quiz = RequestQuiz.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request_quiz.nil?

    @title = "Hita CRM | Editar: #{request_quiz.title}"
    @request_quiz = request_quiz
    @data = request_quiz.data
  end

  def update
    request_quiz = RequestQuiz.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if request_quiz.nil?

    request_quiz.title = params[:title]
    request_quiz.data = params[:data]

    user = User.find_by id: params[:user_id]
    raise ActiveRecord::RecordNotFound if user.nil?

    cycles = search_cycles params[:data]

    if cycles.length > 0
      flash[:alert] = "Não podem ocorrer ciclos nas perguntas. Verifique os ciclos entre as seguintes perguntas: #{cycles}"
      return redirect_to edit_request_quiz_url(request_quiz.id)
    end

    request_quiz.user = user
    request_quiz.save

    Equipment.all.each do |equipment|
      if request_quiz.id.in? equipment.questions
        equipment.update(updated_at: DateTime.current)
      end
    end

    if request_quiz.save
      flash[:notice] = 'O bloco foi atualizado com sucesso'
    else
      flash[:alert] = 'Ocorreu um erro ao atualizar o bloco'
    end

    redirect_to request_quiz_index_url
  end

  def update_position
    positions = params[:positions]

    RequestQuiz.all.each do |quiz|
      quiz.update(position: positions[quiz.id.to_s])
    end

    Equipment.update(updated_at: DateTime.current)
    head :ok
  end

  def destroy
    request_quiz = RequestQuiz.find_by id: params[:id]
    RequestQuiz.where('position > ?', request_quiz.position).update_all('position = position - 1')

    if request_quiz&.destroy
      flash[:notice] = 'O bloco foi removido com sucesso'
    else
      flash[:alert] = 'Ocorreu um erro ao remover o bloco'
    end

    redirect_to request_quiz_index_url
  end

  def search_cycles chatbot_data
    require 'rgl/adjacency'

    graph = RGL::DirectedAdjacencyGraph.new
    chatbot = JSON.parse(chatbot_data)

    chatbot["questions"].each do |question|
      question["answers"].each do |answer|
        edge_from = question["id"].to_i
        edge_to = answer["next"].to_i

        graph.add_edge(edge_from, edge_to) if edge_to > 0
      end
    end

    return graph.cycles
  end

  def get_quiz_data
    equipment = Equipment.find_by id: params[:id]
    request_quiz_data = RequestQuiz.where(id: equipment.questions).order(position: 'ASC')
    request_quiz_data = request_quiz_data.pluck(:data)

    return render json: {}, status: :internal_server_error if equipment.nil?
    return render json: request_quiz_data, status: :ok
  end

  def get_request_quiz_identifiers
    quiz = RequestQuiz.find_by id: params[:id]
    raise ActiveRecord::RecordNotFound if quiz.nil?

    return render json: quiz.get_quiz_ids.as_json, status: :ok
  end
end
