class NotifyAirbrake
  def self.run_for(ex)
    Airbrake.notify(ex)
  rescue
    Rails.logger.error('Airbrake notification failed. Logging error locally only')
    Rails.logger.error(ex.message)
  end
end
