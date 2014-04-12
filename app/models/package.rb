class Package
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :tracking
  embeds_one :image

  field :process_at,  :type => String
  field :department,  :type => String
  field :description, :type => String
  field :status,      :type => String
  field :reciever,    :type => String
  field :signature,   :type => String
  field :notification,:type => String, default: false
  field :notification_by,:type => String, default: ''

  def save_file_from_url(url)
    self.image = Image.new(attachment: URI.parse(url)) unless url.blank?
  end
end
