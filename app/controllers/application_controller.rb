class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :configure_permitted_parameters, if: :devise_controller?
  helper_method :require_user, :require_tracking_code, :require_merchant, :require_admin
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    if((request.params['reset_password_token'].present? || ['sessions', 'passwords'].include?(request.params[:controller])) &&
      (resource.has_role?(:merchant)))
      return stores_root_url
    elsif(resource.roles.blank?)
      return root_url
    end
    request.referer
  end

  def after_sign_up_path_for(resource)
    debugger
    if resource.has_role?(:merchant)
      stores_root_url
    end
  end

  def after_inactive_sign_up_path_for(resource)
    if resource.has_role?(:merchant)
      return redirect_to stores_root_url
    else
      return redirect_to root_url
    end
  end

  def after_sign_out_path_for(resource)
    request.referrer
  end

  def require_admin
    if current_user.present? && current_user.has_any_role?(:admin, :god)
      return @user = current_user
    end
    flash[:alert] = 'Permission Access Denied or Please login again'
    return redirect_to pagpos_url
  end

  def require_tracking_code
    @code = params[:code].present? ? params[:code] : params[:tracking][:code].present? ? params[:tracking][:code] : nil
    if @code.blank?
      return render status: 200, message: 'Bad request', json:{ success: false, error: 'Invalid tracking code' }
    end
  end

  def require_user
    if current_user.present? && params[:token].blank?
      return @user = current_user
    end

    token = params[:token].present? ? params[:token] : params[:tracking].present? && params[:tracking][:token].present? ? params[:tracking][:token] : nil
    @user = User.where(_id: token).first
    if @user.blank?
      flash[:alert] = 'Permission Access Denied or Please login again'
      return redirect_to pagpos_url
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
    # There are just three actions in Devise that allows any set of parameters to be passed down to the model,
    # therefore requiring sanitization. Their names and the permited parameters by default are:

    # sign_in (Devise::SessionsController#new) - Permits only the authentication keys (like email)
    # sign_up (Devise::RegistrationsController#create) - Permits authentication keys plus password and password_confirmation
    # account_update (Devise::RegistrationsController#update) - Permits authentication keys plus password, password_confirmation
    # and current_password. More at https://github.com/plataformatec/devise#strong-parameters

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:accept_invitation) do |u|
        u.permit(:email, :password,:password_confirmation, :invitation_token)
      end

      devise_parameter_sanitizer.for(:invite) do |u|
        u.permit()
      end

      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:email, :password, :password_confirmation, :time_zone, :roles, roles_attributes: [:id, :name])
      end

      devise_parameter_sanitizer.for(:sign_in) do |u|
        u.permit(:email, :password, :password_confirmation, :remember_me)
      end

      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(:password, :password_confirmation, :current_password, :email, :reminder_when, :reminder_by, :phone_no, :name, :gender, :time_zone, store_detail_attributes: [:id, :name, :phone1, :phone2, :description, :address, :city, :district, :province, :postal_code, :email])
      end
    end
end
