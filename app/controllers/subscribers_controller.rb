class SubscribersController < ApplicationController
  def create
    @found = Subscriber.where(email: params[:email]).count > 0
    if(@found)
      flash[:error] = I18n.t('subscriber.add_fail')
      return redirect_to root_url
    else
      @subscriber = Subscriber.new(email: params[:email])
      if @subscriber.save
        flash[:success] = I18n.t('subscriber.add_success')
        return redirect_to root_url
      else
        flash[:error] = I18n.t('subscriber.add_fail')
        render :controller => "welcome", :action => "index"
      end
    end
  end
end
