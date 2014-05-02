require Rails.root.join('lib', 'payment_gateway', 'paypal', 'payment.rb').to_path

class Payment
  module Paypal
    include PaypalPayment

    def self.with_paypal(params={})
      payment_with_paypal(params)
    end

    def self.with_credit_card(params={})
      payment_with_credit_card(params)
    end

    def self.details(payment_id=nil, payer_id=nil, count=10)
      details(payment_id, payer_id, count)
    end

    private
      def payment_with_credit_card(params)
        PaypalPayment.with_credit_card(params)
      end

      def payment_with_paypal(params)
        PaypalPayment.with_paypal(params)
      end

      def details(payment_id, payer_id, count)
        PaypalPayment.details(payment_id, payer_id, count)
      end
  end
end