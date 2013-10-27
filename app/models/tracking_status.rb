class TrackingStatus
  @default_status = I18n.t('tracking_status.default_status')
  @pending  = I18n.t('tracking_status.pending')
  @ontheway = I18n.t('tracking_status.ontheway')
  @done     = I18n.t('tracking_status.done')
  @guest    = I18n.t('tracking_status.guest')

  def self.default_status; @default_status; end
  def self.all_status; [@pending, @ontheway, @done, @guest]; end
  def self.pending; @pending; end
  def self.ontheway; @ontheway; end
  def self.done; @done; end
  def self.guest; @guest; end

  def self.current_status(tracking)
    if tracking.blank?
      return
    else
      if tracking.packages.count.zero?
        status = @pending
      elsif tracking.packages.map(&:reciever).reject(&:empty?).blank?
        status = @ontheway
      else
        status = @done
      end
      return status
    end
  end
end