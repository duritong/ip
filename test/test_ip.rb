begin
    require 'rubygems'
    gem 'test-unit'
rescue LoadError => e 
end

require 'test/unit'
load 'lib/ip.rb'

class CIDRTest < Test::Unit::TestCase

  def name
    return "IP::CIDR tests"
  end

  def test_init_generic
    assert_raise(IP::AddressException) { IP::CIDR.new(Hash.new) }
    assert_raise(IP::AddressException) { IP::CIDR.new("foomatic_wootmaster/32") } 
  end

  def test_init_ipv6
    assert_raise(IP::AddressException) { IP::CIDR.new("F00F:DEAD:BEEF::") }
    assert_raise(IP::AddressException) { IP::CIDR.new("F00F:DEAD:BEEF::/") }
    assert_raise(IP::AddressException) { IP::CIDR.new("F00F:DEAD:BEEF::/asdf/32") }
    assert_raise(IP::AddressException) { IP::CIDR.new("F00F:DEAD:BEEF::/foomatic_wootmaster") }
    assert_raise(IP::AddressException) { IP::CIDR.new("F00F:DEAD:BEEF::/255.255.255.255") }

    cidr = nil
    assert_nothing_raised() { cidr = IP::CIDR.new("F00F:DEAD:BEEF::0001/128") } 

    # this sort of indirectly tests the ipv6 address manipulation.
    assert_equal("F00F:DEAD:BEEF::1", cidr.ip.short_address, "ipv6 object constructed clean")
    assert_equal(128, cidr.mask, "mask is set properly")
    assert_equal("F00F:DEAD:BEEF::0001/128", cidr.cidr, "original CIDR preserved")
  end

  def test_init_ipv4
    assert_raise(IP::AddressException) { IP::CIDR.new("10.0.0.1") }
    assert_raise(IP::AddressException) { IP::CIDR.new("10.0.0.1/") }
    assert_raise(IP::AddressException) { IP::CIDR.new("10.0.0.1/asdf/32") }
    assert_raise(IP::AddressException) { IP::CIDR.new("10.0.0.1/foomatic_wootmaster") }
    assert_raise(IP::AddressException) { IP::CIDR.new("10.0.0.1/255") }

    cidr = nil

    assert_nothing_raised() { cidr = IP::CIDR.new("10.0.0.1/32") } 
    
    assert_equal("10.0.0.1", cidr.ip.ip_address, "ipv4 data integrity test #1")
    assert_equal(32, cidr.mask, "ipv4 data integrity test #2")
    assert_equal("10.0.0.1/32", cidr.cidr, "ipv4 data integrity test #3")

    assert_nothing_raised() { cidr = IP::CIDR.new("10.0.0.1/255.255.255.255") }

    assert_equal("10.0.0.1", cidr.ip.ip_address, "ipv4 data integrity test #4")
    assert_equal(32, cidr.mask, "ipv4 data integrity test #5")
    assert_equal("10.0.0.1/255.255.255.255", cidr.cidr, "ipv4 data integrity test #6")
  end

  def test_netmasks
    cidr = nil 
    assert_nothing_raised() { cidr = IP::CIDR.new("10.0.0.1/32") }
    assert_equal(32, cidr.short_netmask, "ipv4 netmask test #1")
    assert_equal("255.255.255.255", cidr.long_netmask.ip_address, "ipv4 netmask test #2")
    
    assert_nothing_raised() { cidr = IP::CIDR.new("10.0.0.1/255.255.255.248") }
    assert_equal(29, cidr.short_netmask, "ipv4 netmask test #3")
    assert_equal("255.255.255.248", cidr.long_netmask.ip_address, "ipv4 netmask test #4")

    assert_nothing_raised() { cidr = IP::CIDR.new("F00F:DEAD::/16") }
    assert_equal(16, cidr.short_netmask, "ipv6 has proper short netmask")
    assert_raise(IP::AddressException) { cidr.long_netmask } 
  end

  def test_first_last
    cidr = nil
    assert_nothing_raised() { cidr = IP::CIDR.new("10.0.0.2/24") }
    assert_equal("10.0.0.0", cidr.first_ip.ip_address, "ipv4 first/last test #1")
    assert_equal("10.0.0.255", cidr.last_ip.ip_address, "ipv4 first/last test #2")
  end

  def test_range
    cidr = nil
    assert_nothing_raised() { cidr = IP::CIDR.new("10.0.0.2/24") }
    assert_equal(1, cidr.range.find_all { |x| x.ip_address == "10.0.0.1" }.length, "ipv4 range test #1")
    assert_equal(0, cidr.range.find_all { |x| x.ip_address == "10.0.1.0" }.length, "ipv4 range test #2")

    assert_nothing_raised() { cidr = IP::CIDR.new("::0001/120") }
    assert_equal(1, cidr.range.find_all { |x| x.ip_address == "0:0:0:0:0:0:0:00FF" }.length, "ipv6 range test (included)")
    assert_equal(0, cidr.range.find_all { |x| x.ip_address ==" 0:0:0:0:0:0:0:0F00" }.length, "ipv6 range test (not included)")
  end

  def test_overlaps
    cidr, cidr2 = [nil, nil]
    
    assert_nothing_raised() do 
      cidr = IP::CIDR.new("10.0.0.2/24")
      cidr2 = IP::CIDR.new("10.0.0.1/29")
    end

    assert(cidr.overlaps?(cidr2), "ipv4 overlaps test #1")

    assert_nothing_raised() { cidr2 = IP::CIDR.new("10.0.0.1/16") }

    assert(cidr2.overlaps?(cidr), "ipv4 overlaps test #2")
    assert(cidr.overlaps?(cidr2), "ipv4 overlaps test #3")

    assert_nothing_raised() do 
      cidr  = IP::CIDR.new("F00F:DEAD::/16")
      cidr2 = IP::CIDR.new("F00F:BEEF::/16")
    end 

    assert(cidr.overlaps?(cidr2), "ipv6 #overlaps? reports correctly #1")
    assert(cidr2.overlaps?(cidr), "ipv6 #overlaps? reports correctly #2")
  end
  
  def test_includes
    cidr, ip = [nil, nil]
    assert_nothing_raised() do 
      cidr = IP::CIDR.new("10.0.0.2/24")
      ip = IP::Address::IPv4.new("10.0.0.1")
    end

    assert(cidr.includes?(ip), "ipv4 #includes? reports correctly (included)")
    
    assert_nothing_raised() { ip = IP::Address::IPv4.new("10.0.1.0") }

    assert(!cidr.includes?(ip), "ipv4 #includes? reports correctly (not included)")
   
    assert_nothing_raised() do 
      cidr = IP::CIDR.new("FF00::/16")
      ip = IP::Address::IPv6.new("FF00::DEAD")
    end
    assert(cidr.includes?(ip), "ipv6 #includes? reports correctly (included)")
    
    assert_nothing_raised() { ip = IP::Address::IPv6.new("F000::DEAD") } 

    assert(!cidr.includes?(ip), "ipv6 #includes? reports correctly (not included)")
  end

end

class RangeTest < Test::Unit::TestCase
  def name
    return "IP::Range tests"
  end

  def test_range_generic
    assert_raise(IP::AddressException) { IP::Range[Hash.new, ""] } 
    assert_raise(IP::AddressException) { IP::Range["", Hash.new] } 
    assert_raise(IP::AddressException) { IP::Range[IP::Address::IPv6.new("F00F::"), IP::Address::IPv4.new("10.0.0.1")]  }
    assert_raise(IP::AddressException) { IP::Range[IP::Address::IPv4.new("10.0.0.1"), IP::Address::IPv6.new("F00F::")] } 
  end

  def test_range_ipv6
    assert_nothing_raised() do 
      IP::Range["::0001", "::00F0"] 
      IP::Range[IP::Address::IPv6.new("::0001"), IP::Address::IPv6.new("::00F0")]
    end

    range = nil
    
    assert_nothing_raised() { range = IP::Range["::0001", "::0010"] } 
    
    assert_equal(1, range.find_all { |x| x.short_address == "::1" }.length, "ipv6 range check #1")
    assert_equal(1, range.find_all { |x| x.short_address == "::0010" }.length, "ipv6 range check #2")
    assert_equal(1, range.find_all { |x| x.short_address == "::000A" }.length, "ipv6 range check #3")
    assert_equal(0, range.find_all { |x| x.short_address == "::0011" }.length, "ipv6 range check #4")
  end

  def test_range_ipv4
    assert_nothing_raised() do 
      IP::Range["10.0.0.1", "10.0.0.2"]
      IP::Range[IP::Address::IPv4.new("10.0.0.1"), IP::Address::IPv4.new("10.0.0.2")]
    end

    range = nil
    assert_nothing_raised() { range = IP::Range["10.0.0.1", "10.0.0.10"] }

    assert_equal(1, range.find_all { |x| x.ip_address == "10.0.0.1" }.length, "ipv4 range check #1")
    assert_equal(1, range.find_all { |x| x.ip_address == "10.0.0.10" }.length, "ipv4 range check #2")
    assert_equal(1, range.find_all { |x| x.ip_address == "10.0.0.7" }.length, "ipv4 range check #3")
    assert_equal(0, range.find_all { |x| x.ip_address == "10.0.0.11" }.length, "ipv4 range check #4")
  end

end

class IPv6AddressTest < Test::Unit::TestCase
  def name
    return "IP::Address::IPv6 tests"
  end
  
  def test_init
    assert_nothing_raised() do
      IP::Address::IPv6.new("0000:0000:0000:0000:0000:0000:0000:0001")
      IP::Address::IPv6.new("::0001")
      IP::Address::IPv6.new("FF00::")
      IP::Address::IPv6.new("FF00::0001")
      IP::Address::IPv6.new("FF00:BEEF::0001")
      IP::Address::IPv6.new("FF00::BEEF:0001")
      IP::Address::IPv6.new("::1.2.3.4")
      IP::Address::IPv6.new("FFFF::1.2.3.4")
      IP::Address::IPv6.new("FFFF:0000:0000:0000:0000:0000:1.2.3.4")
    end
    
    # now, the tests that should fail

    assert_raise(IP::AddressException) { IP::Address::IPv6.new("FF00:BEEF:") } 
    assert_raise(IP::AddressException) { IP::Address::IPv6.new("FF00::BEEF::") } 
    assert_raise(IP::AddressException) { IP::Address::IPv6.new("FF00::BEEF::DEAD") }
    assert_raise(IP::AddressException) { IP::Address::IPv6.new("HF00::0001") }
    assert_raise(IP::AddressException) { IP::Address::IPv6.new("1.2.3.4::0001") } 
  end

  def test_accessors
    ip = nil
    assert_nothing_raised() { ip = IP::Address::IPv6.new("F00F::DEAD:BEEF") } 

    assert_equal(ip[0], ip.octet(0), "ip[0] eq ip.octet(0)")
    assert_equal(61455, ip[0], "ip[0] is correct")
    assert_equal("F00F", ip.octet_as_hex(0), "octet converts to hex properly")
    assert_equal("F00F::DEAD:BEEF", ip.ip_address, '#ip_address preserves original address')
  end

  def test_address
    ip = nil
    assert_nothing_raised() { ip = IP::Address::IPv6.new("F00F::DEAD:BEEF") }
    assert_equal("F00F::DEAD:BEEF", ip.short_address, 'wildcard left - #short_address returns a compressed version')
    assert_equal("F00F:0:0:0:0:0:DEAD:BEEF", ip.long_address, 'wildcard left - #long_address returns the right thing')

    assert_nothing_raised() { ip = IP::Address::IPv6.new("F00F:DEAD::BEEF") }
    assert_equal("F00F:DEAD::BEEF", ip.short_address, 'wildcard right - #short_address returns a compressed version')
    assert_equal("F00F:DEAD:0:0:0:0:0:BEEF", ip.long_address, 'wildcard right - #long_address returns the right thing')

    assert_nothing_raised() { ip = IP::Address::IPv6.new("F00F:DEAD:0:0:0:0:0:BEEF") }
    assert_equal("F00F:DEAD::BEEF", ip.short_address, 'no wildcard - #short_address returns a compressed version')
    assert_equal("F00F:DEAD:0:0:0:0:0:BEEF", ip.long_address, 'no wildcard - #long_address returns the right thing')

    assert_nothing_raised() { ip = IP::Address::IPv6.new("F00F::DEAD:BEEF:0:0") }
    assert_equal("F00F:0:0:0:DEAD:BEEF::", ip.short_address, '#short_address returns a compressed version with wildcard @ right')
  end

end


class IPv4AddressTest < Test::Unit::TestCase
  def name
    return "IP::Address::IPv4 tests"
  end

  def test_init
    assert_raise(IP::AddressException) { IP::Address::IPv4.new(Hash.new) } 
    assert_raise(IP::AddressException) { IP::Address::IPv4.new("asdf") }
    assert_raise(IP::AddressException) { IP::Address::IPv4.new("0.0.0") }
    assert_raise(IP::AddressException) { IP::Address::IPv4.new("256.255.255.255") } 
    assert_raise(IP::AddressException) { IP::Address::IPv4.new("255.255.255.255aaaa") }
    assert_raise(IP::AddressException) { IP::Address::IPv4.new("255.255.255.") }
  end
  
  def test_accessor
    ip = nil
    assert_nothing_raised() { ip = IP::Address::IPv4.new("10.1.2.3") }
    assert_equal("10.1.2.3", ip.ip_address, "accessor test #1")
    assert_equal(10, ip.octets[0], "accessor test #2")
    assert_equal(3, ip.octets[3], "accessor test #3")
    assert_equal(nil, ip.octets[4], "accessor test #4")
   
    assert_equal(ip.octet(1), ip[1],  "accessor test #5") 
    assert_equal(1, ip[1], "accessor test #5") 

    assert_raise(IP::BoundaryException) { ip[4] }
  end

end

class UtilTest < Test::Unit::TestCase
  def name
    return "IP::Address::Util tests"
  end
  
  def test_pack_unpack
    address = "10.0.0.1"
    assert_equal("10.0.0.1", IP::Address::Util.unpack(IP::Address::Util.pack(IP::Address::IPv4.new(address))).ip_address, "pack/unpack test")
  end
  
  def test_short_netmask
    ip = nil
    assert_nothing_raised() { ip = IP::Address::IPv4.new("255.255.255.255") }
    assert_equal(32, IP::Address::Util.short_netmask(ip), "Short Netmask Test #1")
    assert_nothing_raised() { ip = IP::Address::IPv4.new("255.255.255.248") }
    assert_equal(29, IP::Address::Util.short_netmask(ip), "Short Netmask Test #2")
  end

  def test_long_netmask
    assert_equal("255.255.255.255", IP::Address::Util.long_netmask_ipv4(32).ip_address, "Long Netmask Test #1")
    assert_equal("255.255.255.248", IP::Address::Util.long_netmask_ipv4(29).ip_address, "Long Netmask Test #2")
  end

end
