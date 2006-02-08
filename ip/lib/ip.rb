#
# IP - Collection of Tools to work with IP addresses
#
# Version:: 0.1.0
# Author:: Erik Hollensbe
# License:: BSD
# Contact:: erik@hollensbe.org
#
# IP is, as mentioned above, a collection of tools to work
# with IP addresses. There are three major classes included
# in the IP namespace, IP::Address, which works with standard
# dotted-quad IP addresses, IP::Range, which can calculate and return
# a range of IP::Address objects, and IP::CIDR, which can work with
# Classless Inter-Domain Routing address formats.
#
# The IP module uses long integers and bit-flipping per <netinet/in.h>
# to achieve fairly efficient performance, as opposed to a purely
# iterative approach. This is most true when calculating ranges and
# netmasks.
#
# Please see the documentation for each of these classes for usage
# information.
#
# Note: there is no IPv6 support as of current, but this is planned in
# perhaps a distant, future release. Any patches that can correct this
# issue are most welcome.
#
# Also: Thanks to Tim Howe, who did a lot of initial bug testing and
# 'trial by fire' as this package came out of it's shell. Writing new
# methods that made code easier to understand and/or clearer, and
# making plenty of suggestions made creating this module much easier.
#
# ================================================================
#
# The compilation of software known as ip.rb is distributed under the
# following terms:
# Copyright (C) 2005-2006 Erik Hollensbe. All rights reserved.
#
# Redistribution and use in source form, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

class IP

  #
  # A IP::AddressException is thrown when an IP address cannot be
  # parsed.
  #

  class AddressException < Exception
  end

  #
  # A IP::BoundaryException is thrown when an index is being used out of
  # it's pre-defined boundary. This is most relevant when using the []
  # method in IP::Address.
  #

  class BoundaryException < Exception
  end

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

  #
  # IP::CIDR - Works with Classless Inter-Domain Routing formats, such
  # as 10.0.0.1/32 or 10.0.0.1/255.255.255.255
  #
 
  class CIDR
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

  #
  # IP::Address - utility class to work with dotted-quad IP addresses.
  #
  class Address
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
    # When given a string, constructs an IP::Address object.
    #
    def initialize(ip_address)
      if ! ip_address.kind_of? String
        raise IP::AddressException.new("Fed IP address is not String")
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
    # Returns an octet given the proper index. The octets returned are
    # Integer types.
    #
    def [](num)
      if num > 3
        raise IP::BoundaryException.new("Max octet number is 3")
      end
      return @octets[num]
    end
    
    #
    # See [].
    #
    alias_method :octet, :[]

    #
    # Class method to pack an IP::Address object into a long integer
    # used for calculation. Returns a 'FixNum' type.
    #
    # This method is deprecated. Please use IP::Address::Util#pack instead.
    #
    def Address.pack(ip)
      warn "IP::Address#pack is deprecated. Please use IP::Address::Util#pack instead."
      return IP::Address::Util.pack(ip)
    end

    #
    # Class method to take a 'FixNum' type and return an IP::Address
    # object.
    #
    # This method is deprecated. Please use IP::Address::Util#unpack instead.
    #
    def Address.unpack(ip)
      warn "IP::Address#unpack is deprecated. Please use IP::Address::Util#unpack instead."
      return IP::Address::Util.unpack(ip)
    end
      
  end

end

module IP::Address::Util
  #
  # Pack an IP::Address object into a long integer
  # used for calculation. Returns a 'FixNum' type.
  #
  def pack(ip)
    ret = 0
    myip = ip.octets.reverse
    4.times { |x| ret = ret | (myip[x] & 0xFF) << 8*x }
    return ret
  end
  
  module_function :pack
  
  #
  # Take a 'FixNum' type and return an IP::Address object.
  #
  def unpack(ip)
    ret = []
    4.times { |x| ret.push((ip >> 8*x) & 0xFF) }
    return IP::Address.new(ret.reverse.join("."))
  end
  
  module_function :unpack

  #
  # Given an IP::Address object suitable for a netmask, returns the CIDR-notation
  # "short" netmask.
  #
  # ex:
  # short_netmask(IP::Address.new("255.255.255.255")) => 32
  # short_netmask(IP::Address.new("255.255.255.240")) => 28
  #

  def short_netmask(ip)
    a = []
    (0..3).each do |x|
      if x < 3 && ip[x] < 255 && ip[x+1] > 0
        raise IP::BoundaryException.new("Invalid Netmask")
      end
      a += binary_vector(ip[x])
    end
    retval = 0
    a.each { |x| retval += x }
    return retval
  end

  module_function :short_netmask

  #
  # Given a CIDR-notation "short" netmask, returns a IP::Address object containing
  # the equivalent "long" netmask.
  #
  # ex:
  # long_netmask(32) => IP::Address object of "255.255.255.255"
  # long_netmask(28) => IP::Address object of "255.255.255.240"
  #

  def long_netmask(short)
    raw = 0xFFFFFFFF << (32 - short)
    return IP::Address::Util.unpack(raw)
  end

  module_function :long_netmask

  #
  # Given a number (presumably an octet), will produce a binary vector indicating the
  # on/off positions as 1 or 0.
  #
  # ex:
  # binary_vector(255) => [1, 1, 1, 1, 1, 1, 1, 1]
  # binary_vector(240) => [1, 1, 1, 1, 0, 0, 0, 0]
  #

  def binary_vector(octet)
    return octet.to_i.to_s(2).split(//).collect { |x| x.to_i }
  end

  module_function :binary_vector

end
