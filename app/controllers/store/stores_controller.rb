class Store::StoresController < Devise::RegistrationsController
  before_filter :require_merchant, except: [:index]
  layout false

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

  def new
  end

  def create
  end
end
