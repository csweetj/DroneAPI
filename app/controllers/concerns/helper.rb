module Helper
  extend ActiveSupport::Concern

  def format_seconds_to_time(seconds)
    hours, remainder = seconds.divmod(3600)
    minutes, seconds = remainder.divmod(60)
    format("%02d:%02d:%02d", hours, minutes, seconds)
  end
end