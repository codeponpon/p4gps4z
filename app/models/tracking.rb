class Tracking
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :packages, dependent: :destroy
  belongs_to :user
  validates :code, presence: true, uniqueness: true, format: { with: /\A[E|C|R|L][A-Z][0-9]{9}[0-9A-Z]{2}\Z/ }, length: { is: 13 }
  field :code, type: String
  field :status, type: String, default: "pending"
end
