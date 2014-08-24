module AdUtils

  class User
  
    NORMAL_USER_FLAG = '66048'
    
    attr_reader :uid, :password, :last_name, :first_name
    
    def initialize(opts = {})
      @uid        = opts.fetch(:uid)
      @password   = opts.fetch(:password, nil)
      @last_name  = opts.fetch(:last_name, nil)
      @first_name = opts.fetch(:first_name, nil)
    end
    
    def object
      filter = Net::LDAP::Filter.eq("sAMAccountName", uid)
      AdUtils.connection.search(filter: filter).first
    end
    
    def current_logon_hours
      raise "No AD user defined" if object.nil?
      Helpers.code_to_bin( object[:logonHours].first )
    end
  
    def dn
      @dn ||= "CN=#{ uid }, CN=Users, #{ AdUtils.config.connection[:base]} "
    end
    
    def base_attributes
      @base_attributes ||= {}.tap do |o|
        o[:cn] = uid
        o[:samAccountName] = uid
        o[:sn] = last_name if last_name
        o[:givenName] = first_name if first_name
        o[:objectClass] = 'user'
      end
    end
  
    def create
      return unless object.nil?
      AdUtils.connection.add(dn: dn, attributes: base_attributes)
      AdUtils.connection.modify(dn: dn, operations: [
        [ :replace, :unicodePwd, encoded_password ],
        [ :replace, :userAccountControl, NORMAL_USER_FLAG ],
        [ :replace, :logonHours, Helpers.empty_logon_hours ]
      ])
      Array(AdUtils.config.base_groups).each do |group|
        AdUtils.connection.add_attribute group, :member, dn
      end
    end
  
    def delete
      AdUtils.connection.delete(dn: dn) unless object.nil?
    end
  
    def encoded_password
      @encoded_password ||= begin
        raise 'No password provided' unless password
        Helpers.encode_password(password)
      end
    end    
  
  end

end
