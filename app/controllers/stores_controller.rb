class StoresController < Devise::RegistrationsController
  before_filter :require_merchant, except: [:index, :register, :forgot_password]
  layout 'backend'

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def index
    redirect_to stores_root_path if current_user.present?
  end

  def dashboard
    @page_title = I18n.t('backend.menu.dashboard')
  end

  def list
  end

  def register
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

  def account_update_params
    params.require(:user).permit(:password, :password_confirmation, :current_password, :reminder_when, :reminder_by, :phone_no, :name, :gender, :time_zone, store_detail_attributes: [:id, :name, :phone1, :phone2, :description, :address, :city, :district, :province, :postal_code, :email])
  end
end
