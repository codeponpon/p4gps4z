class Api::V1::TrackingsController < ApplicationController
  before_filter :require_user, :require_tracking_code

  def show
    tracking = @user.trackings.where(code: @code).first
    if not tracking.blank?
      response = {
        code: tracking.code,
        status: tracking.status,
        craeted_at: tracking.created_at,
        updated_at: tracking.updated_at
      }
      return render status: 200, message: 'OK', json: { success: true, data: response }
    else
      return render status: 400, message: 'Bad request', json: { status: false, error: 'Invalid code' }
    end
  end

  def destroy
    tracking = @user.trackings.where(code: @code).first
    if tracking.blank?
      return render status: 400, message: 'Bad request', json: { success: false, error: 'Invalid tracking code' }
    else
      return render status: 200, message: 'OK', json: { success: true, message: 'Delete tracking code successfully' }
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

  private
    def require_tracking_code
      @code = params[:code].present? ? params[:code] : params[:tracking][:code].present? ? params[:tracking][:code] : nil
      if @code.blank?
        return render status: 200, message: 'Bad request', json:{ success: false, error: 'Invalid tracking code' }
      end
    end
end
