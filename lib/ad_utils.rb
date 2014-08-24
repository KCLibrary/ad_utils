require "ad_utils/version"
require 'ostruct'
require 'net/ldap'
require 'ad_utils/helpers'
require 'ad_utils/user'
require 'ad_utils/reservation'


module AdUtils
  def self.config
    @config ||= OpenStruct.new
  end
  
  def self.configure
    yield config if block_given?
  end
  
  def self.connection
    @connection ||= begin
      raise 'No connection defined' unless AdUtils.config.connection
      Net::LDAP.new(AdUtils.config.connection)
    end
  end
  
end
