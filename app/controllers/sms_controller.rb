require 'payment_gateway/payment' #if Rails.env.production? || Rails.env.staging?
require 'money'
require 'money/bank/google_currency'

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
        flat[:error] = result.error.name + ' has something went wrong'
        return redirect_to :packages
      else
        invoice = current_user.pag_invoices.new
        invoice.payment_code = result.id
        invoice.description = params[:payment_transaction_description]
        if invoice.save
          cu = current_user.campaigns_users.new
          cu.campaign_id = @campaign.id
          cu.payment_gateway = params[:type]
          cu.save
          return redirect_to store_invoice_url(result.id)
        else
          # Save invoice fail
        end
      end
    end
  end

  private
    def validate_require_params
      currency_accepted = ["USD", "GBP", "CAD", "EUR", "JPY"]
      require_params = ["intent", "payment_method", "type", "number", "expire_month", "expire_year", "cvv2", "first_name", "last_name", "line1", "city", "state", "postal_code", "country_code", "campaign_name", "campaign_price", "currency", "quantity", "total", "currency", "payment_transaction_description"]
      params[:payment_method] = ['visa', 'mastercard'].include?(params[:type]) ? 'credit_card' : 'paypal'
      params[:number] = params[:number].class.eql?(Fixnum) ? params[:number] : params[:number].gsub(/\s+/, '').to_i
      unless currency_accepted.include?(params[:currency].upcase)
        bank = Money::Bank::GoogleCurrency.new
        rate = bank.get_rate(:USD, params[:currency].to_sym).to_f
        params[:campaign_price]   = params[:campaign_price].to_f / rate
        params[:campaign_price]   = Integer(params[:campaign_price] * 100) / Float(100)
        params[:currency]   = params[:currency].downcase.eql?('usd') ? params[:currency] : 'USD'
      end
      params[:total]        = params[:campaign_price] * params[:quantity].to_i
      params.delete_if do |param|
        !require_params.include?(param.to_s)
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
