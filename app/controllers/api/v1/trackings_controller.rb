class Api::V1::TrackingsController < ApplicationController
  before_filter :require_user, :require_tracking_code

  def show
    tracking = @user.trackings.where(code: @code).first
    if not tracking.blank?
      response = []
      tracking.packages.each do |package|
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
        code: tracking.code,
        status: tracking.status,
        craeted_at: tracking.created_at,
        updated_at: tracking.updated_at 
      }
      return render status: 200, message: 'OK', json: result
    else
      return render status: 400, message: 'Bad request', json: { status: false, error: 'Invalid code' }
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
      return render status: 200, message: 'OK', json: { success: true, message: 'Tracking code has been deleted.' }
    else
      return render status: 200, message: 'OK', json: { success: false, errors: tracking.errors.full_messages }
    end
  end

  def create
    track = @user.trackings.new(code: @code)
    if track.save
      return render :status => 200, message: 'OK', :json => { success: true, message: "Add tracking code successfully"}
    else
      return render :status => 400, message: 'Bad request', :json => { success: false, error: @track.errors.full_messages[0]}
    end
  end

  def require_tracking_code
    @code = params[:code].present? ? params[:code] : params[:tracking][:code].present? ? params[:tracking][:code] : nil
    if @code.blank?
      return render status: 200, message: 'Bad request', json:{ success: false, error: 'Invalid tracking code' }
    end
  end
end
