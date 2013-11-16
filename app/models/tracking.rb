class Tracking
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :packages, dependent: :destroy
  belongs_to :user
  validates :code, presence: true, uniqueness: {:scope => :user_id}, format: { with: /\A[E|C|R|L][A-Z][0-9]{9}[0-9A-Z]{2}\Z/ }, length: { is: 13 }
  
  field :code, type: String
  field :description, type: String
  field :status, type: String, default: TrackingStatus.default_status
  field :packages_count, type: Integer, default: 0
  field :prev_packages_count, type: Integer, default: 0
  field :last_department, type: String

  def tracking_position
    puts "#{Time.now } #{self.code} added to tracking_position queue"
    Resque.enqueue(TrackingPositionWorker, [self.user_id.to_s, self.code])
  end

  def enqueue_send_email_worker
    puts "#{Time.now } #{self.code} added to enqueue_send_email_worker queue"
    reminder_when = self.user.reminder_when
    tracking_id   = self.id.to_s
    specific_department = (self.user.specific_department == self.packages.last.department)
    Resque.enqueue(SendEmailWorker, [tracking_id, reminder_when, specific_department])
  end

  def enqueue_send_sms_worker
    puts "#{Time.now } #{self.code} added to enqueue_send_sms_worker queue"
    reminder_when = self.user.reminder_when
    if self.packages.map(&:reciever).reject(&:nil?).last.blank?
      message = "#{self.code} #{I18n.t('package_status.to', department: self.packages.last.department)}"
    else
      message = "#{self.code} #{I18n.t('package_status.recieved_by', reciever: self.packages.last.reciever)}"
    end
    specific_department = (self.user.specific_department == self.packages.last.department)
    params = [self.user.phone_no, message, reminder_when, specific_department]
    Resque.enqueue(SendSmsWorker, params, self.id.to_s)
  end

  def update_tracking_status
    self.update_attribute(:prev_packages_count, self.packages_count)
    unless self.packages.map(&:reciever).reject(&:empty?).blank?
      self.update_attribute(:status, TrackingStatus.done)
    end
  end
end
