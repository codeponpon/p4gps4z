class CampaignsUser
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :campaign
  belongs_to :user

  field :expire_date, type: DateTime
end
