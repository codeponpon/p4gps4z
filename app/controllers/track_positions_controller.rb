class TrackPositionsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @trackings = current_user.trackings
  end
end
