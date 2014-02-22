class Store::StoresController < Devise::RegistrationsController
  before_filter :require_merchant, except: [:index, :login]
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
  end

  def new
  end

  def login
  end

  def create
  end

  private
    def require_merchant
      if current_user.present?
        return
      end
      redirect_to store_login_url
    end
end
