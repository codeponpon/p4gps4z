class TrackingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_user
  before_filter :require_tracking_code, except: :new

  def new
    @tracking = Tracking.new
  end

  def show
    @tracking = @user.trackings.where(code: @code).first
    if not @tracking.blank?
      response = []
      @tracking.packages.each_with_index do |package, index|
        response << {
          process_at: package.process_at,
          department: package.department,
          description: package.description,
          status: package.status,
          reciever: package.reciever,
          signature: package.signature
        }
      end
      
      result = {
        success: true, 
        data: response, 
        code: @tracking.code,
        status: @tracking.status,
        craeted_at: @tracking.created_at,
        updated_at: @tracking.updated_at 
      }
      # return render status: 200, message: 'OK', json: result
    else
      flash[:alert] = "Something wrong!!!"
      redirect_to :action => "new"
      # return render status: 400, message: 'Bad request', json: { status: false, message: 'Invalid code' }
    end
  end

  def create
    @tracking = @user.trackings.new(code: @code)
    if @tracking.save
      flash[:notice] = "Add tracking code successfully"
      redirect_to :action => "new"
      # return render :status => 200, message: 'OK', :json => { success: true, message: "Add tracking code successfully"}
    else
      render :action => "new"
      # return render :status => 400, message: 'Bad request', :json => { success: false, errors: @track.errors.full_messages[0]}
    end
  end

  def destroy
    tracking = @user.trackings.where(code: @code).first    
    tracking.packages.destroy_all
    status = false;
    if tracking.packages.blank?
      status = true if tracking.destroy
    end

    if status
      flash[:notice] = "Tracking has been deleted."
      redirect_to :action => "new"
      # return render status: 200, message: 'OK', json: { success: true, message: 'Tracking code has been deleted.' }
    else
      redirect_to :action => "new"
      # return render status: 200, message: 'OK', json: { success: false, errors: tracking.errors.full_messages }
    end
  end
end
