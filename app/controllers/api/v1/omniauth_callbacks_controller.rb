class Api::V1::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)

    if @user.persisted?
      # flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "your Facebook"
      # sign_in_and_redirect @user, :event => :authentication
      render :json=> {:success => true, :token => @user.id.to_s}
    else
      # session["devise.facebook_data"] = env["omniauth.auth"]
      # redirect_to new_user_registration_url
      failure
    end
  end
  
  # def open_id
  #   @user = User.find_for_open_id(env["omniauth.auth"], current_user)
  #   
  #   if @user.persisted?
  #     flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "OpenID"
  #     sign_in_and_redirect @user, :event => :authentication
  #   else
  #     session["devise.google_data"] = env["omniauth.auth"]
  #     redirect_to new_user_registration_url
  #   end
  # end
  
  def google
    @user = User.find_for_open_id(env["omniauth.auth"], current_user, 'google')
    session["devise.google_data"] = env["omniauth.auth"]
      # redirect_to new_user_registration_url
    if @user.persisted?
      # flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "your Google"
      # sign_in_and_redirect @user, :event => :authentication
      render :json=> {:success => true, :token => @user.id.to_s}
    else
      # session["devise.google_data"] = env["omniauth.auth"]
      # redirect_to new_user_registration_url
      failure
    end
  end
  
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def failure
    return render json: { success: false, errors: [t('api.v1.sessions.invalid_login')] }, :status => :unauthorized
  end
end