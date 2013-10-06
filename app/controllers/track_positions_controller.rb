class TrackPositionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :trackings

  def index
    @tracking = Tracking.new
  end

  def create
    tracking = params[:tracking]
    @tracking = Tracking.new(code: tracking[:code], user_id: tracking[:user_id])
    if @tracking.save
      return render 'index'
    else
      return render 'index'
    end
  end

  def show
    code = params[:code]
    @tracking = current_user.trackings.where(code: code).first
    if @tracking.blank?
      flash[:notice] = 'Record not found or You havn\'t permission to view'
      redirect_to action: 'index'
    end
  end

  private
    def trackings
      @trackings = current_user.trackings
    end
end
