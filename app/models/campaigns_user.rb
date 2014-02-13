class CampaignsUser
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :campaign
  belongs_to :user

  field :payment_code, type: String
  field :payment_gateway, type: String, default: ''
end
