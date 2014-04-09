class SmsController < ApplicationController
  before_filter :require_merchant
  layout 'backend'

  def index
  end

  def packages
    @page_title = I18n.t('page_title.packages')
    @campaigns = Campaign.all
  end
end
