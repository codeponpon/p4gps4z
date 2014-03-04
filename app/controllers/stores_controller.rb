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
  end
end
