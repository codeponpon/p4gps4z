class StoreDetail
  include Mongoid::Document
  embedded_in :user

  field :name,        type: String, default: ''
  field :description, type: String, default: ''
  field :address,     type: String, default: ''
  field :city,        type: String, default: ''
  field :district,    type: String, default: ''
  field :province,    type: String, default: ''
  field :postal_code, type: Integer, default: ''
  field :url,         type: String, default: ''
  field :email,       type: String, default: ''
  field :phone1,      type: String, default: ''
  field :phone2,      type: String, default: ''
  field :logo,        type: String, default: ''
end
