class StoresController < Devise::RegistrationsController
  before_filter :require_merchant, except: [:index, :register, :create, :forgot_password]
  before_filter :permitt_parameters, only: [:create, :update_profile]
  layout 'backend'

  def resource_name
    :user
  end

  def resource
    resource ||= User.new
  end

  def devise_mapping
    devise_mapping ||= Devise.mappings[:user]
  end

  def index
    redirect_to stores_root_path if current_user.present? && current_user.has_any_role?(:merchant, :god)
  end

  def dashboard
    @page_title = I18n.t('backend.menu.dashboard')
  end

  def list
  end

  def register
  end

  def create
    resource = build_resource(sign_up_params)

    if resource.save
      resource.roles.create(name: 'merchant', resource_type: 'merchant', resource_id: resource.id)
      # UserMailer.welcome(resource).deliver unless resource.invalid?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        return redirect_to stores_root_path
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        return redirect_to action: :index
      end
    else
      clean_up_passwords resource
      flash[:error] = resource.errors.full_messages
      render :register
    end
  end

  def forgot_password
  end

  def profile
    @page_title = 'Profile details'
    @user = User.where(id: current_user.id).first
    @user.build_store_detail if @user.store_detail.blank?
  end

  def update_profile
    @user = User.where(id: current_user.id).first
    update_result = if params[:user][:password].blank?
      params[:user].delete('current_password')
      @user.update_without_password(account_update_params)
    else
      @user.update_with_password(account_update_params)
    end
    # debugger
    if update_result
      set_flash_message :success, :updated
      sign_in resource_name, @user
      render :profile
    else
      clean_up_passwords @user
      render :profile
    end
  end

  private
    def permitt_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:email, :password, :password_confirmation, :time_zone, :roles, roles_attributes: [:id, :name])
      end

      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(:password, :password_confirmation, :current_password, :email, :reminder_when, :reminder_by, :phone_no, :name, :gender, :time_zone, store_detail_attributes: [:id, :name, :phone1, :phone2, :description, :address, :city, :district, :province, :postal_code, :email])
      end
    end
end
