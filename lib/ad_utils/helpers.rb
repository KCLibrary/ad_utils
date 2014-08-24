module AdUtils
  class Helpers
    def self.encode_password(pwd)
      ['"', *pwd.chars, '"'].map do |char|
        "#{char}\000"
      end.join
    end
    
    def self.bin_to_code(str)
      str.scan(/.{8}/).map do |byte|
        byte.reverse.to_i(2)
      end.pack('c*').force_encoding('UTF-8')
    end
  
    def self.code_to_bin(str)
      str.unpack('b*').join
    end
    
    def self.empty_logon_hours
      bin_to_code( '0' * 168 )
    end
    
  end
end
