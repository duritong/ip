#
# IP::CIDR - Works with Classless Inter-Domain Routing formats, such
# as 10.0.0.1/32 or 10.0.0.1/255.255.255.255
#

class IP::CIDR
  #
  # Contains the original CIDR you fed it, returned as a string.
  #
  attr_reader :cidr
  #
  # Contains the IP address (LHS) only. Returned as an IP::Address
  # object.
  #
  attr_reader :ip
  #
  # Contains the integer-based (short) netmask (RHS) only. Returned as an
  # integer.
  #
  attr_reader :mask
  
  #
  # Given a string of format X.X.X.X/X, in standard CIDR notation,
  # this will construct a IP::CIDR object.
  #
  def initialize(cidr)
    if !cidr.kind_of? String
      raise IP::AddressException.new("CIDR value is not of type String")
    end
    
    @cidr = cidr
    @ip, @mask = cidr.split(/\//, 2)
    
    if @ip.nil? or @mask.nil?
      raise IP::AddressException.new("CIDR is not valid - invalid format")
    end
    
    if @mask.length == 0 or /[^0-9.]/.match @mask
      raise IP::AddressException.new("CIDR RHS is not valid - #{@mask}")
    end
    
    if @mask.length > 2
      # this will throw an exception if the netmask is malformed.
      @mask = IP::Address::Util.short_netmask(IP::Address.new(@mask))
    end
    
    @ip = IP::Address.new(@ip)
    @mask = @mask.to_i
  end
  
  def netmask
    warn "IP::CIDR#netmask is deprecated. Please use IP::CIDR#long_netmask instead."
    return self.long_netmask
  end
  
  #
  # This produces the long netmask (eg. 255.255.255.255) of the CIDR in an
  # IP::Address object.
  #
  def long_netmask
    return IP::Address::Util.long_netmask(@mask)
  end
  
  #
  # This produces the short netmask (eg. 32) of the CIDR in an IP::Address
  # object.
  #
  
  def short_netmask
    return @mask
  end
  
  #
  # This produces a range ala IP::Range, but only for the subnet
  # defined by the CIDR object.
  #
  def range
    return IP::Range[self.first_ip, self.last_ip]
  end
  
  #
  # This returns the first ip address of the cidr as an IP::Address object.
  #
  def first_ip
    rawip = IP::Address::Util.pack(@ip)
    rawnm = 0xFFFFFFFF << (32 - @mask)
    lower = rawip & rawnm
    return IP::Address::Util.unpack(lower)
  end
  
  #
  # This returns the last ip address of the cidr as an IP::Address object.
  #
  def last_ip
    rawip = IP::Address::Util.pack(@ip)
    rawnm = 0xFFFFFFFF << (32 - @mask)
    upper = rawip | ~rawnm
    return IP::Address::Util.unpack(upper)
  end
  
  #
  # This will take another IP::CIDR object as an argument and check to see
  # if it overlaps with this cidr object. Returns true/false on overlap.
  #
  # This also throws a TypeError if passed invalid data.
  #
  def overlaps?(other_cidr)
    raise TypeError.new("Expected object of type IP::CIDR") unless(other_cidr.kind_of?(IP::CIDR))
    
    myfirst = IP::Address::Util.pack(self.first_ip)
    mylast = IP::Address::Util.pack(self.last_ip)
    
    otherfirst = IP::Address::Util.pack(other_cidr.first_ip)
    otherlast = IP::Address::Util.pack(other_cidr.last_ip)
    
    return ((myfirst >= otherfirst && myfirst <= otherlast) ||
              (mylast <= otherlast && mylast >= otherfirst) ||
              (otherfirst >= myfirst && otherfirst <= mylast)) ? true : false;
  end
  
end
