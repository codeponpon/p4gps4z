require Rails.root.join('lib', 'payment_gateway', 'paypal', 'payment.rb').to_path

class Pagment
  module Paypal
    include PaypalPayment

    def self.with_paypal(params={})
      PaypalPayment.with_paypal(params)
    end

    def self.with_credit_card(params={})
      PaypalPayment.with_credit_card(params)
    end

    def self.details(payment_id=nil, payer_id=nil, count=10)
      PaypalPayment.details(payment_id, payer_id, count)
    end
  end
end