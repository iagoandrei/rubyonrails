class FormKeysController < ApplicationController
  def index
    @title = 'Hita CRM | Chaves'
    @form_keys = FormKey.all.order(key_name: 'ASC')
    @avaliable_quizzes = RequestQuiz.all.pluck(:title, :id)
  end

  def create
    form_key = FormKey.new form_key_params
    quiz = RequestQuiz.find_by id: params[:form_key][:request_quiz_id]

    form_key.request_quiz = quiz
    form_key.conditions = params[:conditions]
    form_key.answers_to_print = params[:form_key][:answers_to_print]

    if form_key.save
      flash[:notice] = 'A chave foi criada com sucesso'
    else
      flash[:alert] = 'Houve um erro ao criar a chave'
    end

    redirect_to form_keys_index_url
  end

  def edit
    @title             = 'Hita CRM | Chaves'
    @form_keys         = FormKey.all.order(key_name: 'ASC')
    @avaliable_quizzes = RequestQuiz.all.pluck(:title, :id)
    @form_key          = FormKey.find_by_id params[:id]
  end

  def update
    form_key = FormKey.find_by_id params[:form_key][:id]

    if form_key.update form_key_params
      flash[:notice] = 'A chave foi atualizada com sucesso'
    else
      flash[:alert] = 'Erro ao atualizar chave'
    end

    redirect_to edit_form_keys_path(form_key.id)
  end

  def destroy
    form_key = FormKey.find_by id: params[:id]

    if form_key&.destroy
      flash[:notice] = 'A chave foi removida com sucesso'
    else
      flash[:alert] = 'Ocorreu um erro ao remover a chave'
    end

    redirect_to form_keys_index_url
  end

private
  def form_key_params
    params.require(:form_key).permit(:key_name, :content, :conditions, :is_answer_printable, :answers_to_print)
  end
end
