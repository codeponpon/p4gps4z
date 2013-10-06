class Api::V1::TrackingsController < ApplicationController
  before_filter :authenticate_user!

  def create
    tracking_code = params[:tracking_code]
    @track = current_user.trackings.new(code: tracking_code)
    if @track.save
      render :status => 200, message: 'OK', :json => { success: true, message: "Add tracking code successfully"}
    else
      return render :status => 400, message: 'Bad request', :json => { success: false, errors: @track.errors.full_messages[0]}
    end
  end
end
