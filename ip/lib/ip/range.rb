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

class Range
  
  #
  # See the documentation for IP::Range for more information on this
  # method.
  #
  
  def Range.[](addr1, addr2)
    raw1, raw2 = [nil, nil]
    
    if addr1.kind_of? String
      raw1 = IP::Address::Util.pack(IP::Address.new(addr1))
    elsif addr1.kind_of? IP::Address
      raw1 = IP::Address::Util.pack(addr1)
    else
      raise IP::AddressException("IP Address is not type String or IP::Address")
    end
    
    if addr2.kind_of? String
      raw2 = IP::Address::Util.pack(IP::Address.new(addr2))
    elsif addr2.kind_of? IP::Address
      raw2 = IP::Address::Util.pack(addr2)
    else
      raise IP::AddressException("IP Address is not type String or IP::Address")
    end
    
    range = []
    
    (raw1..raw2).each { |x| range.push(IP::Address::Util.unpack(x)) }
    
    return range
  end
end
