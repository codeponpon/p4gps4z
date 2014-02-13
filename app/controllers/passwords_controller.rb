class PasswordsController < Devise::PasswordsController
  layout 'backend'

  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
  end

end
