class CommissionsController < ApplicationController
  before_action :set_commission, only: [:show, :edit, :update, :destroy]

  # GET /commissions
  # GET /commissions.json
  def index
    @commissions = Commission.all
  end

  # GET /commissions/1
  # GET /commissions/1.json
  def show
  end
  def get_commis_by_id    
    comis = Commission.find_by request_id: params[:request_id]
    raise ActiveRecord::RecordNotFound if comis.nil?
    render json: comis.as_json  
  end

  # GET /commissions/new
  def new
    @commission = Commission.new
  end

  # GET /commissions/1/edit
  def edit
  end

  # POST /commissions
  # POST /commissions.json
  def create
    @commission = Commission.new(commission_params)

    respond_to do |format|
      if @commission.save
        format.html { redirect_to @commission, notice: 'Commission was successfully created.' }
        format.json { render :show, status: :created, location: @commission }
      else
        format.html { render :new }
        format.json { render json: @commission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /commissions/1
  # PATCH/PUT /commissions/1.json
  def update
    respond_to do |format|
      if @commission.update(commission_params)
        format.html { redirect_to @commission, notice: 'Commission was successfully updated.' }
        format.json { render :show, status: :ok, location: @commission }
      else
        format.html { render :edit }
        format.json { render json: @commission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commissions/1
  # DELETE /commissions/1.json
  def destroy
    @commission.destroy
    respond_to do |format|
      format.html { redirect_to commissions_url, notice: 'Commission was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commission
      @commission = Commission.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def commission_params
      params.require(:commission).permit(:represent, :value, :paydate, :paid, :request_id)
    end
end
