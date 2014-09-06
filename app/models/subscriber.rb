class Subscriber
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  index({ email: 1 } , { unique: true })
end
