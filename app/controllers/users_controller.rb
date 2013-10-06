class UsersController < Devise::RegistrationsController
  before_filter :authenticate_user!

  def index
  end

  def edit
    @user = current_user
  end

  def update
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    logger.debug(params[:user])
    if resource.update_with_password(account_update_params)
      if is_navigational_format?
        update_needs_confirmation?(resource, prev_unconfirmed_email)
      end
      sign_in resource_name, resource
      return render 'edit'
    else
      clean_up_passwords resource
      return render 'edit'
    end
  end

  def account_update_params
    params.require(:user).permit( :email, :password, :password_confirmation, :current_password, :reminder_when, :reminder_by)
  end
end
