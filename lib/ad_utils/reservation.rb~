module AdUtils

  class Reservation
    
    TIME_ZONE = 'CDT'
    
    attr_reader :uid, :start_time, :end_time
    
    def initialize(opts = {})
      @uid        = opts.fetch(:uid)
      @start_time = opts.fetch(:start_time)
      @end_time   = opts.fetch(:end_time)
    end
  
    def user; User.new(uid: uid); end
  
    def modify(b)
      AdUtils.connection.replace_attribute user.dn, :logonHours, logon_hours_formatted(b)
    end
    
    def create; modify('1'); end
    def delete; modify('0'); end    

    def duration
      ((end_time - start_time) / 3600).to_i
    end
    
    def index
      now   = start_time.to_a.tap {|o| o[-1] = TIME_ZONE }
      local = Time.local(*now)
      utc   = Time.utc(*now)
      bias  = local.dst? ? 1 : 0      
      (utc.wday * 24) + (utc.hour) + bias
    end
    
    def logon_hours_formatted(b)
      v = user.current_logon_hours.chars.to_a.fill(b, index, duration).join
      Helpers.bin_to_code v
    end
  
  end
end
