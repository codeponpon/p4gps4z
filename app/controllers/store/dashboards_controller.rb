class Store::DashboardsController < ApplicationController
  before_filter :require_merchant
  layout 'backend'
  def index
  end
end
