class Store::DashboardsController < Store::StoresController
  before_filter :require_merchant
  def index
  end
end
