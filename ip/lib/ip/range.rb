#
# IP::Range - Calculates a range of IP addresses, and returns an
# Array of IP::Address objects.
#
# Usage::
#
# IP::Range['10.0.0.1', '10.0.0.2'] => IP::Address objects between
# 10.0.0.1 and 10.0.0.2 (inclusive)
#
# IP::Range can also take two IP::Address objects.
#
# Will throw a IP::AddressException if for some reason addresses
# cannot be parsed.
#

class IP::Range
  
  #
  # See the documentation for IP::Range for more information on this
  # method.
  #
  
  def self.[](addr1, addr2)
    raw1, raw2 = [nil, nil]
    tmpip = nil
    
    if addr1.kind_of? String
      addr1 = IP::Address::Util.string_to_ip(addr1)
    elsif ! addr1.kind_of? IP::Address
      raise IP::AddressException("IP Address is not type String or IP::Address")
    end
    
    if addr2.kind_of? String
      addr2 = IP::Address::Util.string_to_ip(addr2)
    elsif ! addr2.kind_of? IP::Address
      raise IP::AddressException("IP Address is not type String or IP::Address")
    end

    if addr2.class.name != addr1.class.name
      raise IP::AddressException.new("First and Second IP in range are not of the same type")
    end
    
    raw1 = addr1.pack
    raw2 = addr2.pack

    range = []
    
    # use the class we were given to force certain results, instead
    # of relying on the fairly inaccurate unpack facility.
    range = (raw1..raw2).collect { |x| addr1.class.new(x) }

    return range
  end
end
