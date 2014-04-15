class CampaignsUser
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :campaign
  belongs_to :user

  payment_gateway type: String
end
