class SmsController < ApplicationController
  before_filter :require_merchant
  before_filter :search_by
  layout 'backend'

  def index
    @credit = 0;
    @sent = 0;
    @campaigns.each do |cu|
      @credit += cu.campaign.credit
    end

    @trackings = current_user.trackings
    @trackings.each do |t|
      t.packages
    end

  end

  def packages
    @page_title = I18n.t('page_title.campaigns')
    @campaigns = Campaign.all
  end

  private
    def search_by
      params[:filter] = 'day' unless params[:filter]
      case params[:filter]
      when 'all'
        @campaigns = current_user.campaigns_users.all
      when 'week'
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_week, :created_at.lte => DateTime.now.end_of_week)
      when 'month'
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_month, :created_at.lte => DateTime.now.end_of_month)
      when '3months'
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_month, :created_at.lte => DateTime.now.end_of_month.advance(months: +3))
      when '6months'
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_month, :created_at.lte => DateTime.now.end_of_month.advance(months: +6))
      when 'year'
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_year, :created_at.lte => DateTime.now.end_of_year)
      else
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_day, :created_at.lte => DateTime.now.end_of_day)
      end
    end
end
