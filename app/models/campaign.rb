class Campaign
  include Mongoid::Document
  has_many :campaigns_users

  field :name, type: String
  field :credit, type: Integer
  field :unit, type: String
  field :price, type: Float
  field :currency_symbold, type: String, default: '฿'
  field :currency, type: String, default: 'Bath'
  field :popular, type: Boolean, default: false
  field :default, type: Boolean, default: false
  field :color, type: String, default: ''
end
