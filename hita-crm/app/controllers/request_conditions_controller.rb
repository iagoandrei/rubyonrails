class RequestConditionsController < ApplicationController
    before_action :set_request_condition, only: [:show, :edit, :update, :destroy]
  
    # GET /request_conditions
    # GET /request_conditions.json
    def index
      @request_conditions = RequestCondition.all
    end
  
    # GET /request_conditions/1
    # GET /request_conditions/1.json
    def show
    end
  
    # GET /request_conditions/new
    def new
      @request_condition = RequestCondition.new
    end

     
    # GET /request_conditions/1/edit
    def edit
    end
  
    # POST /request_conditions
    # POST /request_conditions.json
    def create
  
      @request_condition = RequestCondition.new(request_condition_params)
      @request_condition.save!
  
  
      respond_to do |format|
        if @request_condition.save
          format.html { redirect_to @request_condition, notice: 'Request condition was successfully created.' }
          format.json { render :show, status: :created, location: @request_condition }
        else
          format.html { render :new }
          format.json { render json: @request_condition.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /request_conditions/1
    # PATCH/PUT /request_conditions/1.json
    def update
      respond_to do |format|
        if @request_condition.update(request_condition_params)
          format.html { redirect_to @request_condition, notice: 'Request condition was successfully updated.' }
          format.json { render :show, status: :ok, location: @request_condition }
        else
          format.html { render :edit }
          format.json { render json: @request_condition.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /request_conditions/1
    # DELETE /request_conditions/1.json
    def destroy
      @request_condition.destroy
      respond_to do |format|
        format.html { redirect_to request_conditions_url, notice: 'Request condition was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
   
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_request_condition
        @request_condition = RequestCondition.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def request_condition_params
        params.require(:request_condition).permit(:payment_type, :operation_type, :storage_center, :payment_code, :request_id)
      end
  end
  