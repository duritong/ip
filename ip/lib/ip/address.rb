#
# IP::Address - base class for IP::Address::IPv4 and IP::Address::IPv6
#

class IP::Address

  #
  # This original IP Address you passed it, returned as a string.
  #
  attr_reader :ip_address
  #
  # This returns an Array of Integer which contains the octets of
  # the IP, in descending order. 
  #
  attr_reader :octets

  #
  # Returns an octet given the proper index. The octets returned are
  # Integer types.
  #
  def [](num)
    if @octets[num].nil?
      raise IP::BoundaryException.new("Invalid octet")
    end
    return @octets[num]
  end
  
  #
  # See [].
  #
  alias_method :octet, :[]
  
  #
  # Returns a 128-bit integer representing the address.
  #
  def pack
    fail "This method is abstract."
  end
end

#
# Support for IPv4
#

class IP::Address::IPv4 < IP::Address
  #
  # Constructs an IP::Address::IPv4 object.
  #
  # This can take two types of input. Either a string that contains
  # a dotted-quad formatted address, or an integer that contains the
  # data. This integer is expected to be constructed in the way that
  # IP::Address::Util.pack_ipv4 would generate such an integer.
  #
  # This constructor will throw IP::AddressException on any parse
  # errors.
  #
  def initialize(ip_address)
    if ip_address.kind_of? Integer
      # unpack to generate a string, and parse that.
      # overwrites 'ip_address'
      # horribly inefficient, but general.
      
      raw = IP::Address::Util.raw_unpack(ip_address)[0..1]
      octets = []
      
      2.times do |x|
        octets.push(raw[x] & 0x00FF)
        octets.push((raw[x] & 0xFF00) >> 8)
      end
      
      ip_address = octets.reverse.join(".")
    end
    
    if ! ip_address.kind_of? String
      raise IP::AddressException.new("Fed IP address '#{ip_address}' is not String or Fixnum")
    end
    
    @ip_address = ip_address
    
    #
    # Unbeknowest by me, to_i will not throw an exception if the string
    # can't be converted cleanly - it just truncates, similar to atoi() and perl's int().
    #
    # Code below does a final sanity check.
    #
    
    octets = ip_address.split(/\./)
    octets_i = octets.collect { |x| x.to_i }
    
    0.upto(octets.length - 1) do |octet|
      if octets[octet] != octets_i[octet].to_s
        raise IP::AddressException.new("Integer conversion failed")
      end
    end
    
    @octets = octets_i
    
    # I made a design decision to allow 0.0.0.0 here.
    if @octets.length != 4 or @octets.find_all { |x| x > 255 }.length > 0
      raise IP::AddressException.new("IP address is improperly formed")
    end
  end

  #
  # Returns a 128-bit integer representing the address.
  #
  def pack
    # this routine does relatively little. all it does is ensure
    # that the IP address is of a certain size and has certain numeric limits.
    myip = self.octets
    packval = [0] * 6
    
    #
    # this ensures that the octets are 8 bit, and combines the octets in order to
    # form two 16-bit integers suitable for pushing into the last places in 'packval'
    #
    
    (0..3).step(2) { |x| packval.push(((myip[x] & 0xFF) << 8) | (myip[x+1] & 0xFF)) }
    
    return raw_pack(packval)
  end
end

class IP::Address::IPv6 < IP::Address

  def initialize(ip_address)
    if ip_address.kind_of? Integer
      # unpack to generate a string, and parse that.
      # overwrites 'ip_address'
      # horribly inefficient, but general.
      
      raw = IP::Address::Util.raw_unpack(ip_address)
      
      ip_address = octets.reverse.collect { |x| "%X" % x }.join(":")
    end
    
    if ! ip_address.kind_of? String
      raise IP::AddressException.new("Fed IP address '#{ip_address}' is not String or Fixnum")
    end
    
    @ip_address = ip_address

    #
    # since IPv6 can have missing parts, we have to scan sequentially.
    # fill the LHS until we encounter '::', at which point we fill the
    # RHS.
    #
    # If the LHS is 8 octets, we're done. Otherwise, we take a
    # difference of 8 and the sum of the number of octets from the LHS
    # from the number of octets from the RHS. We then fill abs(num) at
    # the end of the LHS array with 0, and combine them to form the
    # address.
    #
    # There can only be one '::' in an address, so if we are filling
    # the RHS and encounter another '::', we throw AddressException.
    #
    # TODO: parse IPv4 dotted-quad compatibility addresses.
    #

    octets = ip_address.split(":")

    if octets.length < 8
      
      if octets[-1].index(".").nil?
        
        lhs = []
        rhs = []
        
        i = octets.index("") # find ::
        
        # easy out for xxxx:xxxx:: and so on
        if i.nil?
          lhs = octets.dup
        elsif i == 0
          # catches ::XXXX::
          if ip_address.rindex("::") != 0
            raise IP::AddressException.new("IPv6 address '#{ip_address}' has more than one floating range ('::') specifier")
          end
            
          # for some reason "::123:123".split(":") returns two empty
          # strings in the array, yet a trailing "::" doesn't.
          rhs = octets[2..-1]
        else
          lhs = octets[0..(i-1)]
          rhs = octets[(i+1)..-1]
        end
        
        unless rhs.index("").nil?
          raise IP::AddressException.new("IPv6 address '#{ip_address}' has more than one floating range ('::') specifier")
        end
        
        missing = (8 - (lhs.length + rhs.length))
        missing.times { lhs.push("0") }
        
        octets = lhs + rhs
        
      else
        # we have a dotted quad IPv4 compatibility address.
        # create an IPv4 object, get the raw value and stuff it into
        # the lower two octets. discard everything else.
        
        raw = IP::Address::IPv4.new(octets[-1]).pack
        low = raw & 0xFFFF
        high = raw >> 4
        octets = ([0] * 6) + [high, low]
      end

    elsif octets.length > 8
      raise IP::AddressException.new("IPv6 address '#{ip_address}' has more than 8 octets")
    end

    if octets.length != 8
      raise IP::AddressException.new("IPv6 address '#{ip_address}' does not have 8 octets or a floating range specifier")
    end

    #
    # Now we check the contents of the address, to be sure we have
    # proper hexidecimal values
    #
    
    @octets = []

    octets.each do |x|
      if x.length > 4
        raise IP::AddressException.new("IPv6 address '#{ip_address}' has an octet that is larger than 32 bits")
      end

      octet = x.hex

      # normalize the octet to 4 places with leading zeroes, uppercase.
      x = ("0" * (4 - x.length)) + x.upcase unless octet == 0

      unless ("%X" % octet) == x
        raise IP::AddressException.new("IPv6 address '#{ip_address}' has octets that contain non-hexidecimal data")
      end

      @octets.push(octet)
    end
    
  end

  #
  # Returns an address with no floating range specifier.
  #
  # Ex:
  #
  # IP::Address::IPv6.new("DEAD::BEEF").long_address => "DEAD:0:0:0:0:0:0:BEEF"
  #
  
  def long_address
    return @octets.collect { |x| "%X" % x }.join(":")
  end

  #
  # Returns a shortened address using the :: range specifier.
  #
  # This will replace any sequential octets that are equal to '0' with '::'. 
  # It does this searching from right to left, looking for a sequence
  # of them. Per specification, only one sequence can be replaced in
  # this fashion. It will return a long address if it can't find
  # something suitable.
  #
  # Ex:
  #
  # "DEAD:0:0:0:BEEF:0:0:0" => "DEAD:0:0:0:BEEF::"

  def short_address
    return long_address.reverse.sub(/(0:)+/, "::").reverse
  end
  
  #
  # Returns a 128-bit integer representing the address.
  #
  def pack
    return IP::Address::Util.raw_pack(self.octets.dup)
  end

end