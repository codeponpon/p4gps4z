class TrackingStatus
  @pending  = 'pending'
  @ontheway = 'ontheway'
  @done     = 'done'
  @guest    = 'guest'
  @default_status = @pending

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