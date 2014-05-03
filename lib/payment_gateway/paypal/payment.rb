require 'paypal-sdk-rest'
include PayPal::SDK::REST

module PaypalPayment
  # Build Payment object
  def self.with_credit_card(params={})
    params[:intent]       = "sale" unless params[:intent].present?
    params[:country_code] = "TH" unless params[:country_code].present?
    params[:quantity]     = params[:quantity].present? ? params[:quantity].to_i : 1

    @payment = Payment.new({
      :intent => params[:intent],
      :payer => {
        :payment_method => params[:payment_method],
        :funding_instruments => [{
          :credit_card => {
            :type => params[:type],
            :number => params[:number],
            :expire_month => params[:expire_month],
            :expire_year => params[:expire_year],
            :cvv2 => params[:cvv2],
            :first_name => params[:first_name],
            :last_name => params[:last_name]
            # :billing_address => {
            #   :line1 => params[:line1],
            #   :city => params[:city],
            #   :state => params[:state],
            #   :postal_code => params[:postal_code],
            #   :country_code => params[:country_code] }
          }
        }]
      },
      :transactions => [{
        :item_list => {
          :items => [{
            :name => params[:campaign_name],
            :sku => params[:campaign_name],
            :price => params[:campaign_price],
            :currency => params[:currency],
            :quantity => params[:quantity]
          }]
        },
        :amount => {
          :total => params[:campaign_price],
          :currency => params[:currency] },
        :description => params[:payment_transaction_description] }]})

    # Create Payment and return the status(true or false)
    @payment.create
    return @payment
  end

  def self.details(payment_id=nil, payer_id=nil, count=10)
    # Fetch Payment
    payment = Payment.find(payment_id)

    if payer_id
      if payment.execute( :payer_id => payer_id)
        return payment
      else
        return payment.error # Error Hash
      end
    else
      # Get List of Payments
      payment_history = Payment.all( :count => count )
      return payment_history.payments
    end
  end
end # End Paypay
