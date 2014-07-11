class UsersController < Devise::RegistrationsController
  before_filter :authenticate_user!
  before_filter :require_merchant, only: [:customer, :add_customer]
  before_filter :require_admin, only: [:user]

  layout 'backend', only: [:customer, :user, :add_customer, :edit_customer, :detail_customer, :create_customer, :update_customer, :destroy_customer]

  def index
  end

  def edit
    @user = current_user
  end

  def update
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
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

  def profile
  end

  def customer
    params ||= {}
    @page_title = I18n.t('page_title.customers')
    page = params[:page].present? ? params[:page] : 1
    @users = current_user.customers.paginate(:page => page, :per_page => 20)
  end

  def user
    params ||= {}
    page = params[:page].present? ? params[:page] : 1
    @users = User.paginate(:page => page, :per_page => 20)
  end

  def detail_customer
    params ||= {}
    page = params[:page].present? ? params[:page] : 1
    @page_title = I18n.t('page_title.detail_customer')
    @user = User.where(_id: params[:id]).first
    @user_trackings = @user.trackings.paginate(:page => page, :per_page => 20)
    @tracking = @user.trackings.new
  end

  def add_customer
    @page_title = I18n.t('page_title.add_customer')
    @user = User.new
  end

  def edit_customer
    @page_title = I18n.t('page_title.edit_customer')
    @user = User.where(_id: params[:id]).first
    @user.email = nil if @user.email.scan('@pagpos.com')
  end

  def create_customer
    email = "#{params[:user][:phone_no]}@pagpos.com" if params[:user][:email].blank?
    password = Devise.friendly_token
    params[:user][:email] = email
    params[:user][:password] = password
    params[:user][:password_confirmation] = password

    @user = current_user.customers.new(customer_params)
    if @user.save
      flash[:success] = I18n.t('user.add_customer.success')
      return redirect_to store_customers_url
    else
      render :add_customer
    end
  end

  def update_customer
    email = "#{params[:user][:phone_no]}@pagpos.com" if params[:user][:email].blank?
    params[:user][:email] = email
    update_result = User.where(_id: params[:id]).first
    if update_result.update_attributes(account_update_params)
      flash[:success] = I18n.t('user.update_customer.success')
      return redirect_to store_customers_url
    else
      render :edit_customer
    end
  end

  def destroy_customer
    user = User.where(_id: params[:id]).first
    if user.destroy
      flash[:success] = I18n.t('user.destroy_customer.success')
    else
      flash[:error] = user.errors.full_messages
    end
    return redirect_to store_customers_url
  end

  def customer_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :phone_no, :reminder_by, :gender, :user_reminder_when)
  end

  def account_update_params
    params.require(:user).permit(:password, :password_confirmation, :current_password, :reminder_when, :reminder_by, :phone_no, :email, :name, :gender, :time_zone)
  end

end
