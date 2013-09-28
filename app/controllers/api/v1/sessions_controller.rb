class Api::V1::SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, :only => [:create]
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  # before_filter :validate_auth_token, :except => :create
  include Devise::Controllers::Helpers
  include ApiHelper
  respond_to :json

  def create
    params[:user] = params[:api_v1_user]
    resource = User.find_for_database_authentication(:email => params[:user][:email])
    return failure unless resource
    
    if resource.valid_password?(params[:user][:password])
      sign_in(:api_v1_user, resource)
      token = User.where('_id' => resource.id).first
      unless token.nil?
        render :json=> {:success => true, :token => token.id.to_s}
      else
        failure
      end
      return
    end
    failure
  end

  def destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    render :status => 200, :json => {success: true}
  end

  def failure
    return render json: { success: false, errors: [t('api.v1.sessions.invalid_login')] }, :status => :unauthorized
  end

end
