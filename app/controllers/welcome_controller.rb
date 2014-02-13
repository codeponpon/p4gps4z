class WelcomeController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  layout 'backend', only: [:templates]
  def index
  end

  def templates
  end
end
