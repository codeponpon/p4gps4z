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
  
  def twitter
    auth = env["omniauth.auth"]
    #Rails.logger.info("auth is **************** #{auth.to_yaml}")
    @user = User.find_for_twitter_oauth(request.env["omniauth.auth"],current_user)
    if @user.persisted?
      # flash[:notice] = I18n.t "devise.omniauth_callbacks.success"
      # sign_in_and_redirect @user, :event => :authentication
      render :json=> {:success => true, :token => @user.id.to_s}
    else
      # session["devise.twitter_uid"] = request.env["omniauth.auth"]
      # redirect_to new_user_registration_url
      failure
    end
  end
  
  def google_oauth2     
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      # flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      # sign_in_and_redirect @user, :event => :authentication
      render :json=> {:success => true, :token => @user.id.to_s}
    else
      # session["devise.google_data"] = request.env["omniauth.auth"]
      # redirect_to new_user_registration_url
      failure
    end
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def failure
    return render :status => 401, message: 'Unauthorized',  json: { success: false, errors: [t('api.v1.sessions.invalid_login')] }
  end
end