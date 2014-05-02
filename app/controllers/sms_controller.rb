require 'payment_gateway/payment' #if Rails.env.production? || Rails.env.staging?

class SmsController < ApplicationController
  before_filter :require_merchant
  before_filter :search_by
  layout 'backend'

  def index
    @credit = 0;
    @sent   = 0;
    @campaigns.each do |cu|
      @credit += cu.campaign.credit
    end

    @credit_used = 0;
    @trackings.each do |t|
      t.packages.each do |p|
        @credit_used += 1 if p.notification
      end
    end

  end

  def packages
    @page_title = I18n.t('page_title.campaigns')
    @campaigns  = Campaign.all
  end

  def buy_package
    @page_title = I18n.t('page_title.buy_package')
    @campaign = Campaign.where(id: params[:id]).first
    if params[:type].downcase.eql?('visa') || params[:type].downcase.eql?('mastercard')
      result = Pagment::Paypal.with_credit_card(validate_require_params)
      if result.id.nil? && result.error.present?
        # ERROR
      else
        # DONE
      end
    end
  end

  private
    def validate_require_params
      require_params = ["intent", "payment_method", "type", "number", "expire_month", "expire_year", "cvv2", "first_name", "last_name", "line1", "city", "state", "postal_code", "country_code", "campaign_name", "campaign_name", "campaign_price", "currency", "quantity", "total", "currency", "payment_transaction_description"]
      params.delete_if do |param|
        !require_params.include?(param)
      end
   end

    def search_by
      params[:filter] = 'day' unless params[:filter]
      @trackings      = []
      @customer_count = 0;
      case params[:filter]
      when 'all'
        @campaigns = current_user.campaigns_users.all
        current_user.customers.each do |c|
          @trackings += c.trackings.all
        end
      when 'week'
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_week, :created_at.lte => DateTime.now.end_of_week)
        current_user.customers.each do |c|
          @trackings += c.trackings.where(:created_at.gte => DateTime.now.beginning_of_week, :created_at.lte => DateTime.now.end_of_week)
        end
      when 'month'
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_month, :created_at.lte => DateTime.now.end_of_month)
        current_user.customers.each do |c|
          @trackings += c.trackings.where(:created_at.gte => DateTime.now.beginning_of_month, :created_at.lte => DateTime.now.end_of_month)
        end
      when '3months'
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_month, :created_at.lte => DateTime.now.end_of_month.advance(months: +3))
        current_user.customers.each do |c|
          @trackings += c.trackings.where(:created_at.gte => DateTime.now.beginning_of_month, :created_at.lte => DateTime.now.end_of_month.advance(months: +3))
        end
      when '6months'
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_month, :created_at.lte => DateTime.now.end_of_month.advance(months: +6))
        current_user.customers.each do |c|
          @trackings += c.trackings.where(:created_at.gte => DateTime.now.beginning_of_month, :created_at.lte => DateTime.now.end_of_month.advance(months: +6))
        end
      when 'year'
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_year, :created_at.lte => DateTime.now.end_of_year)
        current_user.customers.each do |c|
          @trackings += c.trackings.where(:created_at.gte => DateTime.now.beginning_of_year, :created_at.lte => DateTime.now.end_of_year)
        end
      else
        @campaigns = current_user.campaigns_users.where(:created_at.gte => DateTime.now.beginning_of_day, :created_at.lte => DateTime.now.end_of_day)
        current_user.customers.each do |c|
          @trackings += c.trackings.where(:created_at.gte => DateTime.now.beginning_of_day, :created_at.lte => DateTime.now.end_of_day)
        end
      end
    end
end
