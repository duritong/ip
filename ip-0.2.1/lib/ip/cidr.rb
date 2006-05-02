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

    @ip = IP::Address::Util.string_to_ip(@ip)

    if @ip.nil? or @mask.nil?
      raise IP::AddressException.new("CIDR is not valid - invalid format")
    end
    
    if @mask.length == 0 or /[^0-9.]/.match @mask or 
        (@ip.kind_of? IP::Address::IPv6 and @mask.to_i.to_s != @mask)
      raise IP::AddressException.new("CIDR RHS is not valid - #{@mask}")
    end

    if @ip.kind_of? IP::Address::IPv4 and @mask.length > 2
      # get the short netmask for IPv4 - this will throw an exception if the netmask is malformed.
      @mask = IP::Address::Util.short_netmask(IP::Address::IPv4.new(@mask))
    end
    
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
  # This will throw an exception for IPv6 addresses.
  #
  def long_netmask
    if @ip.kind_of? IP::Address::IPv6
      raise IP::AddressException.new("IPv6 does not support a long netmask.")
    end
    
    return IP::Address::Util.long_netmask_ipv4(@mask)
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
    rawip = @ip.pack 
    
    #
    # since our actual mask calculation is done with the full 128 bits,
    # we have to shift calculations that we want in IPv4 to the left to
    # get proper return values.
    # 

    if @ip.kind_of? IP::Address::IPv4
      rawip = rawip << 96
    end

    rawnm = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) << (128 - @mask)
    lower = rawip & rawnm

    if @ip.kind_of? IP::Address::IPv4
      lower = lower & (0xFFFFFFFF000000000000000000000000)
      lower = lower >> 96
    end

    case @ip.class.object_id
    when IP::Address::IPv4.object_id
      return IP::Address::IPv4.new(lower)
    when IP::Address::IPv6.object_id
      return IP::Address::IPv6.new(lower)
    else
      raise IP::AddressException.new("Cannot determine type of IP address")
    end

  end
  
  #
  # This returns the last ip address of the cidr as an IP::Address object.
  #
  def last_ip
    rawip = @ip.pack
    
    # see #first_ip for the reason that we shift this way for IPv4.
    if @ip.kind_of? IP::Address::IPv4
      rawip = rawip << 96
    end

    rawnm = (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) << (128 - @mask)
    upper = rawip | ~rawnm

    if @ip.kind_of? IP::Address::IPv4
      upper = upper & (0xFFFFFFFF000000000000000000000000)
      upper = upper >> 96
    end

    case @ip.class.object_id
    when IP::Address::IPv4.object_id
      return IP::Address::IPv4.new(upper)
    when IP::Address::IPv6.object_id
      return IP::Address::IPv6.new(upper)
    else
      raise IP::AddressException.new("Cannot determine type of IP address")
    end
  end
  
  #
  # This will take another IP::CIDR object as an argument and check to see
  # if it overlaps with this cidr object. Returns true/false on overlap.
  #
  # This also throws a TypeError if passed invalid data.
  #
  def overlaps?(other_cidr)
    raise TypeError.new("Expected object of type IP::CIDR") unless(other_cidr.kind_of?(IP::CIDR))
    
    myfirst = self.first_ip.pack
    mylast = self.last_ip.pack
    
    otherfirst = other_cidr.first_ip.pack
    otherlast = other_cidr.last_ip.pack
    
    return ((myfirst >= otherfirst && myfirst <= otherlast) ||
              (mylast <= otherlast && mylast >= otherfirst) ||
              (otherfirst >= myfirst && otherfirst <= mylast)) ? true : false;
  end

  #
  # Given an IP::Address object, will determine if it is included in
  # the current subnet. This does not generate a range and is
  # comparatively much faster.
  #
  # This will *not* generate an exception when IPv4 objects are
  # compared to IPv6, and vice-versa. This is intentional.
  #

  def includes?(address)
    raise TypeError.new("Expected type of IP::Address or derived") unless (address.kind_of? IP::Address)

    raw   = address.pack
    first = first_ip.pack
    last  = last_ip.pack
    
    return (raw >= first) && (raw <= last)
  end

end
