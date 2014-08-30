module AdUtils

  class Reservation
    
    TIME_ZONE = 'CDT'
    
    attr_reader :uid, :start_time, :end_time, :queue_name
    
    def initialize(opts = {})
      unless defined? Delayed::MessageSending
        raise 'Reservation creation depends on Delayed Job'
      end
      @uid        = opts.fetch(:uid)
      @queue_name = opts.fetch(:queue_name, nil)
      @start_time = opts.fetch(:start_time)
      @end_time   = opts.fetch(:end_time)
    end
  
    def user; User.new(uid: uid); end
  
    def modify(b)
      args = [user.dn, :logonHours, logon_hours_formatted(b)]
      AdUtils.connection.replace_attribute *args
    end
    
    def __create__; modify('1'); end
    def __delete__; modify('0'); end    

    def create
      __create__
      __delete__.delay(queue: queue_name, run_at: end_time + 3600)
    end
    
    handle_asynchronously(:create, {
      queue:  Proc.new { |i| i.queue_name },
      run_at: Proc.new { |i| i.start_time - 3600 }
    }) if respond_to?(:handle_asynchronously)
    
    alias_method :delete, :__delete__

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
