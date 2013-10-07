class Tracking
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :packages, dependent: :destroy
  belongs_to :user
  validates :code, presence: true, uniqueness: true, format: { with: /\A[E|C|R|L][A-Z][0-9]{9}[0-9A-Z]{2}\Z/ }, length: { is: 13 }
  
  field :code, type: String
  field :status, type: String, default: "pending"
  field :packages_count, type: Integer, default: 0
  field :prev_packages_count, type: Integer, default: 0
  field :last_department, type: String

  def sendmail_asynchronously
    user = self.user
    if user.reminder_when == 'status_change' && self.prev_packages_count < self.packages_count
      Resque.enqueue(StatusChangeNotificationWorker, self.code)
    elsif user.reminder_when == 'specific_post' && self.last_department != self.packages.last.department
      Resque.enqueue(SpecificPostNotificationWorker, self.code)
      self.update_attribute(:last_department, self.packages.last.department)
    end
  end

  def tracking_position
    Resque.enqueue(TrackingPositionWorker, self.code)
  end

  def update_status
    self.update_attribute(:prev_packages_count, self.packages_count)
    if not self.packages.map(&:reciever).reject(&:empty?).blank?
      self.update_attribute(:status, 'done')
    end
  end
end
