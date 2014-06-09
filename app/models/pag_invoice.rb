class PagInvoice
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user

  field :payment_code, type: String
  field :description, type: String

end
