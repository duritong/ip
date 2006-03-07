#
# General utility functions used by other IP classes.
#

module IP::Address::Util
  #
  # Pack an object into a long integer used for calculation. Returns a
  # 'FixNum' type. Can take both IP::Address::IPv4 and
  # IP::Address::IPv6 objects.
  #
  
  def pack(ip)
    return ip.pack
  end
  
  module_function :pack
  
  #
  # This routine takes an array of integers which are intended to be
  # an IP address, and joins them into a single integer used for easy
  # calculation.
  #
  # IPv4 and IPv6 objects are packed into the same size, a 128-bit
  # integer. This is done for easier processing within the library.
  #
  
  def raw_pack(array)
    ret = 0
    myip = array.reverse
    8.times { |x| ret = ret | myip[x] << 16*x }
    return ret
  end
  
  module_function :raw_pack
  
  #
  # Take an 'Integer' type and return an IP::Address object.
  #
  # This routine will 'guess' at what version of IP addressing you
  # want, returning the oldest type possible (IPv4 addresses will
  # return IP::Address::IPv4 objects).
  #
  # In almost all cases, you'll want to use the type-specific
  # routines, which merely involve passing an Integer to the
  # constructor for each class.
  #
  def unpack(ip)
    ret = raw_unpack(ip)
    
    # any IPv6 address should meet this criteria.
    if ret[2..8].any? { |x| x > 0 }
      return IP::Address::IPv6.new(ip)
    end
    
    return IP::Address::IPv4.new(ip)
  end
  
  module_function :unpack
 
  #
  # Take a 'FixNum' and return it's in-place octet
  # representation. This is mostly a helper method for the unpack
  # routines.
  #
  
  def raw_unpack(ip)
    ret = []
    8.times { |x| ret.push((ip >> 16*x) & 0xFFFF) }
    return ret
  end
  
  module_function :raw_unpack
  
  #
  # Returns a short subnet mask - works for all IP::Address objects.
  #
  # ex:
  # short_netmask(IP::Address::IPv4.new("255.255.255.255")) => 32
  # short_netmask(IP::Address::IPv6.new("2001:0DB8:0000:CD30:0000:0000:0000:0000")) => 60
  #
  
  def short_netmask(ip)
    #
    # This method handles 128-bit integers better for both types of
    # addresses, even though it is a bit slower.
    #
    # TODO: there really is probably a better way to do this.
    #
 
    s = ip.pack.to_s(2)
    s = ("0" * (128 - s.length)) + s

    return s.rindex("1") + 1
  end
  
  module_function :short_netmask
  
  def long_netmask(short)
    warn "This function is deprecated, please use IP::Address::Util.long_netmask_ipv4 instead."
    return long_netmask_ipv4(short)
  end
  
  module_function :long_netmask
  
  #
  # Given a CIDR-notation "short" netmask, returns a IP::Address object containing
  # the equivalent "long" netmask.
  #
  # ex:
  # long_netmask(32) => IP::Address object of "255.255.255.255"
  # long_netmask(28) => IP::Address object of "255.255.255.240"
  #
  
  def long_netmask_ipv4(short)
    raw = (0xFFFFFFFF << (32 - short)) & 0xFFFFFFFF
    return IP::Address::Util.unpack(raw)
  end
  
  module_function :long_netmask_ipv4
  
  #
  # This takes a string which supposedly contains an IP address, and
  # tries to figure out if it is a IPv6 or IPv4 address. Returns a
  # constructed object of the proper type.
  #

  def string_to_ip(s)
    begin
      return IP::Address::IPv6.new(s)
    rescue IP::AddressException => e
      begin
        return IP::Address::IPv4.new(s)
      rescue IP::AddressException => e
        raise IP::AddressException.new("Could not determine address format while trying to calculate range")
      end
    end
  end

  module_function :string_to_ip

end
