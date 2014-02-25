class SmsController < ApplicationController
  before_filter :require_merchant, except: [:index]
  layout 'backend'

  def index
  end
end
