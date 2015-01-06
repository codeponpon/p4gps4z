class WelcomeController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :about]
  layout 'backend', only: [:templates]
  layout 'template2', only: [:about]

  def index
    @subscriber = Subscriber.new
  end

  def templates
  end

  def about

  end
end
