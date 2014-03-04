class StoreMetadata
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user

  field :name,        type: String
  field :description, type: Text
  field :address,     type: String
  field :city,        type: String
  field :district,    type: String
  field :province,    type: String
  field :postal_code, type: Integer
  field :url,         type: String
  field :email,       type: String
  field :phone1,      type: String
  field :phone2,      type: String
  field :logo,        type: String
end
