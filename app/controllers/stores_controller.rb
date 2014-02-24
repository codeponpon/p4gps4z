class StoresController < Devise::RegistrationsController
  before_filter :require_merchant, except: [:index]
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
    redirect_to store_root_path if current_user.present?
  end

  def dashboard
  end
end
