class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  helper_method :require_user
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    track_positions_path
  end

  def require_user
    @user = User.where(_id: params[:token]).first
    if @user.blank?
      return render status: 400, message: 'Bad request', json: { status: false, message: 'Invalid user' }
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

end
