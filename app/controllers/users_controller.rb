class UsersController < Devise::RegistrationsController
  before_filter :authenticate_user!
  before_filter :require_merchant, only: [:customer, :user]
  layout 'backend', only: [:customer, :user]

  def index
  end

  def edit
    @user = current_user
  end

  def update
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    logger.debug(params[:user])
    update_result = if params[:user][:password].blank?
      params[:user].delete('current_password')
      resource.update_without_password(account_update_params)
    else
      resource.update_with_password(account_update_params)
    end
    if update_result
      if is_navigational_format?
        update_needs_confirmation?(resource, prev_unconfirmed_email)
      end
      set_flash_message :notice, :updated
      sign_in resource_name, resource
      return render 'edit'
    else
      clean_up_passwords resource
      return render 'edit'
    end
  end

  def account_update_params
    params.require(:user).permit(:password, :password_confirmation, :current_password, :reminder_when, :reminder_by, :phone_no, :email, :name, :gender, :time_zone)
  end

  def profile
  end

  def customer
  end

  def user
    page = params[:page].present? ? params[:page] : 1
    @users = User.paginate(:page => page, :per_page => 20)
  end
end
