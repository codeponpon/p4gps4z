class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :configure_permitted_parameters, if: :devise_controller?
  helper_method :require_user, :require_tracking_code, :require_merchant
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    request.referer
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

  def require_merchant
    unless current_user.present? && current_user.has_any_role?(:god, :admin, :merchant)
      redirect_to store_login_url
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

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :time_zone) }
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:email, :password) }
    end
end
