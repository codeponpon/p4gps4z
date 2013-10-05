class Image
  include Mongoid::Document
  include Mongoid::Paperclip
  
  embedded_in :package
  has_mongoid_attached_file :attachment,
    :path => ":rails_root/public:url",
    :url => "/systems/signatures/:id/:basename/:styles.:extension",
    :default_url => "/systems/missing.png",
    :styles => {
      :small => "250x250>",
      :thumb => "100x100>"
    }
end