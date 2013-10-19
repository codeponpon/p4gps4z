class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  helper_method :require_user, :require_tracking_code
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    new_tracking_path
  end

  def require_user
    if current_user.present?
      return @user = current_user
    end
    
    token = params[:token].present? ? params[:token] : params[:tracking][:token].present? ? params[:tracking][:token] : nil
    @user = User.where(_id: token).first
    if @user.blank?
      return render status: 400, message: 'Bad request', json: { status: false, message: 'Invalid user' }
    end
  end

  def require_tracking_code
    @code = params[:code].present? ? params[:code] : params[:tracking][:code].present? ? params[:tracking][:code] : nil
    if @code.blank?
      return render status: 200, message: 'Bad request', json:{ success: false, error: 'Invalid tracking code' }
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

end
