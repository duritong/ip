require 'test/unit'
load 'lib/ip.rb'

class CIDRTest < Test::Unit::TestCase

  def name
    return "IP::CIDR tests"
  end

  def test_init_generic
    a = nil

    begin
      IP::CIDR.new(Hash.new)
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "data types test #1")

    begin
      IP::CIDR.new("foomatic_wootmaster/32")
      a = false
    rescue IP::AddressException => e
      a = true
    end
    
    assert(a, "data types test #2")
  end

  def test_init_ipv6
    a = nil

    begin
      IP::CIDR.new("F00F:DEAD:BEEF::")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "ipv6 data validation test #1")

    begin
      IP::CIDR.new("F00F:DEAD:BEEF::/")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "ipv6 data validation test #2")
    
    begin
      IP::CIDR.new("F00F:DEAD:BEEF::/asdf/32")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "ipv6 data validation test #3")
  
    begin
      IP::CIDR.new("F00F:DEAD:BEEF::/foomatic_wootmaster")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "ipv6 data validation test #4")

    begin
      IP::CIDR.new("F00F:DEAD:BEEF::/foomatic_wootmaster")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "ipv6 data validation test #5")

    begin
      IP::CIDR.new("F00F:DEAD:BEEF::/255.255.255.255")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "ipv6 data validation test #6")

    cidr = IP::CIDR.new("F00F:DEAD:BEEF::0001/128")

    # this sort of indirectly tests the ipv6 address manipulation.
    assert(cidr.ip.short_address == "F00F:DEAD:BEEF::1", "ipv6 data integrity test #1")
    assert(cidr.mask == 128, "ipv6 data integrity test #2")
    assert(cidr.cidr == "F00F:DEAD:BEEF::0001/128", "ipv6 data integrity test #3")
  end

  def test_init_ipv4
    a = nil
    
    begin
      IP::CIDR.new("10.0.0.1")
      a = false
    rescue IP::AddressException => e
      a = true
    end
    
    assert(a, "ipv4 data validation test #1")
    
    begin
      IP::CIDR.new("10.0.0.1/")
      a = false
    rescue IP::AddressException => e
      a = true
    end
    
    assert(a, "ipv4 data validation test #2")
    
    begin
      IP::CIDR.new("10.0.0.1/asdf/32")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "ipv4 data validation test #3")
    
    begin
      IP::CIDR.new("10.0.0.1/foomatic_wootmaster")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "ipv4 data validation test #4")

    begin
      IP::CIDR.new("10.0.0.1/255")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "ipv4 data validation test #5")

    cidr = IP::CIDR.new("10.0.0.1/32")
    
    assert(cidr.ip.ip_address == "10.0.0.1", "ipv4 data integrity test #1")
    assert(cidr.mask == 32, "ipv4 data integrity test #2")
    assert(cidr.cidr == "10.0.0.1/32", "ipv4 data integrity test #3")

    cidr = IP::CIDR.new("10.0.0.1/255.255.255.255")

    assert(cidr.ip.ip_address == "10.0.0.1", "ipv4 data integrity test #4")
    assert(cidr.mask == 32, "ipv4 data integrity test #5")
    assert(cidr.cidr == "10.0.0.1/255.255.255.255", "ipv4 data integrity test #6")
  end

  def test_netmasks
    cidr = IP::CIDR.new("10.0.0.1/32")
    assert(cidr.short_netmask == 32, "ipv4 netmask test #1")
    assert(cidr.long_netmask.ip_address == "255.255.255.255", "ipv4 netmask test #2")
    
    cidr = IP::CIDR.new("10.0.0.1/255.255.255.248")
    assert(cidr.short_netmask == 29, "ipv4 netmask test #3")
    assert(cidr.long_netmask.ip_address == "255.255.255.248", "ipv4 netmask test #4")
  end

  def test_first_last
    cidr = IP::CIDR.new("10.0.0.2/24")
    assert(cidr.first_ip.ip_address == "10.0.0.0", "ipv4 first/last test #1")
    assert(cidr.last_ip.ip_address == "10.0.0.255", "ipv4 first/last test #2")
  end

  def test_range
    cidr = IP::CIDR.new("10.0.0.2/24")
    assert(cidr.range.find_all { |x| x.ip_address == "10.0.0.1" }.length == 1, "ipv4 range test #1")
    assert(cidr.range.find_all { |x| x.ip_address == "10.0.1.0" }.length == 0, "ipv4 range test #2")
  end

  def test_overlaps
    cidr = IP::CIDR.new("10.0.0.2/24")
    cidr2 = IP::CIDR.new("10.0.0.1/29")

    assert(cidr.overlaps?(cidr2), "ipv4 overlaps test #1")

    cidr2 = IP::CIDR.new("10.0.0.1/16")

    assert(cidr2.overlaps?(cidr), "ipv4 overlaps test #2")
    assert(cidr.overlaps?(cidr2), "ipv4 overlaps test #3")
  end
end

class RangeTest < Test::Unit::TestCase
  def name
    return "IP::Range tests"
  end

  def test_range_generic
    a = nil
    begin
      IP::Range[Hash.new, ""]
      a = false
    rescue Exception => e
      a = true
    end

    assert(a, "generic data types test #1")

    begin
      IP::Range["", Hash.new]
      a = false
    rescue Exception => e
      a = true
    end

    assert(a, "generic data types test #2")
    
    begin
      IP::Range[IP::Address::IPv6.new("F00F::"), IP::Address::IPv4.new("10.0.0.1")]
      a = false
    rescue Exception => e
      a = true
    end

    assert(a, "generic data types test #3")
    
    begin
      IP::Range[IP::Address::IPv4.new("10.0.0.1"), IP::Address::IPv6.new("F00F::")]
      a = false
    rescue Exception => e
      a = true
    end

    assert(a, "generic data types test #4")
  end

  def test_range_ipv6
    a = nil
    
    begin 
      IP::Range["::0001", "::00F0"]
      a = true
    rescue Exception => e
      a = false
    end

    assert(a, "ipv6 data types test #1")
    
    begin
      IP::Range[IP::Address::IPv6.new("::0001"), IP::Address::IPv6.new("::00F0")]
      a = true
    rescue Exception => e
      a = false
    end

    assert(a, "ipv6 data types test #2")

    range = IP::Range["::0001", "::0010"]

    assert(range.find_all { |x| x.short_address == "::1" }.length == 1, "ipv6 range check #1")
    assert(range.find_all { |x| x.short_address == "::0010" }.length == 1, "ipv6 range check #2")
    assert(range.find_all { |x| x.short_address == "::000A" }.length == 1, "ipv6 range check #3")
    assert(range.find_all { |x| x.short_address == "::0011" }.length == 0, "ipv6 range check #4")
  end

  def test_range_ipv4
    a = nil
    begin
      IP::Range["10.0.0.1", "10.0.0.2"]
      a = true
    rescue Exception => e
      a = false
    end
    
    assert(a, "ipv4 data types test #1")
    
    begin
      IP::Range[IP::Address::IPv4.new("10.0.0.1"), IP::Address::IPv4.new("10.0.0.2")]
      a = true
    rescue Exception => e
      a = false
    end

    assert(a, "ipv4 data types test #2")

    range = IP::Range["10.0.0.1", "10.0.0.10"]

    assert(range.find_all { |x| x.ip_address == "10.0.0.1" }.length == 1, "ipv4 range check #1")
    assert(range.find_all { |x| x.ip_address == "10.0.0.10" }.length == 1, "ipv4 range check #2")
    assert(range.find_all { |x| x.ip_address == "10.0.0.7" }.length == 1, "ipv4 range check #3")
    assert(range.find_all { |x| x.ip_address == "10.0.0.11" }.length == 0, "ipv4 range check #4")
  end

end

class IPv6AddressTest < Test::Unit::TestCase
  def name
    return "IP::Address::IPv6 tests"
  end
  
  def test_init
    a = nil
    
    # test the good data first...

    begin
      IP::Address::IPv6.new("0000:0000:0000:0000:0000:0000:0000:0001")
      a = true
    rescue IP::AddressException => e
      a = false
    end

    assert(a, "full address")

    begin
      IP::Address::IPv6.new("::0001")
      a = true
    rescue IP::AddressException => e
      a = false
    end

    assert(a, "wildcard address, wildcard left")

    begin
      IP::Address::IPv6.new("FF00::")
      a = true
    rescue IP::AddressException => e
      a = false
    end

    assert(a, "wildcard address, wildcard right")

    begin
      IP::Address::IPv6.new("FF00::0001")
      a = true
    rescue IP::AddressException => e
      a = false
    end

    assert(a, "wildcard address, wildcard center")

    begin
      IP::Address::IPv6.new("FF00:BEEF::0001")
      a = true
    rescue IP::AddressException => e
      a = false
    end

    assert(a, "wildcard address, wildcard center with two leading")

    begin
      IP::Address::IPv6.new("FF00::BEEF:0001")
      a = true
    rescue IP::AddressException => e
      a = false
    end

    assert(a, "wildcard address, wildcard center with two trailing")

    begin
      IP::Address::IPv6.new("::1.2.3.4")
      a = true
    rescue IP::AddressException => e
      puts e
      a = false
    end

    assert(a, "IPv4 address in IPv6, wildcard left")

    begin
      IP::Address::IPv6.new("FFFF::1.2.3.4")
      a = true
    rescue IP::AddressException => e
      a = false
    end

    assert(a, "IPv4 in IPv6, data on wildcard @ left")

    begin
      IP::Address::IPv6.new("FFFF:0000:0000:0000:0000:0000:1.2.3.4")
      a = true
    rescue IP::AddressException => e
      a = false
    end
    
    assert(a, "IPv4 in IPv6, no wildcard")

    # now, the tests that should fail
    
    begin
      IP::Address::IPv6.new("FF00::BEEF::")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "double wildcard no trailer")

    begin
      IP::Address::IPv6.new("FF00::BEEF::DEAD")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "double wildcard w/ trailer")

    begin
      IP::Address::IPv6.new("HF00::0001")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "invalid hexidecimal")
    
    begin
      IP::Address::IPv6.new("1.2.3.4::0001")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "invalid IPv4 in IPv6")

  end

  def test_accessors
    ip = IP::Address::IPv6.new("F00F::DEAD:BEEF")

    assert(ip[0] == 61455 && ip.octet(0) == 61455, "#octet is integer representation, #[] is #octet")
    assert(ip.octet_as_hex(0) == "F00F", "octet converts to hex properly")
    assert(ip.ip_address == "F00F::DEAD:BEEF", '#ip_address preserves original address')
  end

  def test_address
    ip = IP::Address::IPv6.new("F00F::DEAD:BEEF")
    assert(ip.short_address == "F00F::DEAD:BEEF", 'wildcard left - #short_address returns a compressed version')
    assert(ip.long_address == "F00F:0:0:0:0:0:DEAD:BEEF", 'wildcard left - #long_address returns the right thing')

    ip = IP::Address::IPv6.new("F00F:DEAD::BEEF")
    assert(ip.short_address == "F00F:DEAD::BEEF", 'wildcard right - #short_address returns a compressed version')
    assert(ip.long_address == "F00F:DEAD:0:0:0:0:0:BEEF", 'wildcard right - #long_address returns the right thing')

    ip = IP::Address::IPv6.new("F00F:DEAD:0:0:0:0:0:BEEF")
    assert(ip.short_address == "F00F:DEAD::BEEF", 'no wildcard - #short_address returns a compressed version')
    assert(ip.long_address == "F00F:DEAD:0:0:0:0:0:BEEF", 'no wildcard - #long_address returns the right thing')

    ip = IP::Address::IPv6.new("F00F::DEAD:BEEF:0:0")
    assert(ip.short_address == "F00F:0:0:0:DEAD:BEEF::", '#short_address returns a compressed version with wildcard @ right')
  end

end


class IPv4AddressTest < Test::Unit::TestCase
  def name
    return "IP::Address::IPv4 tests"
  end

  def test_init
    ip = nil
    begin
      ip = IP::Address::IPv4.new(Hash.new)
    rescue IP::AddressException => e
      assert(true, "init test #1")
    end

    assert(false, "init test #2") if ip

    ip = nil

    begin
      ip = IP::Address::IPv4.new("asdf")
    rescue IP::AddressException => e
      assert(true, "init test #2")
    end

    assert(false, "init test #2") if ip
    ip = nil

    begin
      ip = IP::Address::IPv4.new("0.0.0")
    rescue IP::AddressException => e
      assert(true, "init test #3")
    end

    assert(false, "init test #3") if ip
    ip = nil
    
    begin
      ip = IP::Address::IPv4.new("256.255.255.255")
    rescue IP::AddressException => e
      assert(true, "init test #4")
    end

    assert(false, "init test #4") if ip

    ip = nil
    begin
      ip = IP::Address::IPv4.new("255.255.255.255aaaa")
    rescue IP::AddressException => e
      assert(true, "init test #5")
    end

    assert(false, "init test #5") if ip

    ip = nil
    begin
      ip = IP::Address::IPv4.new("255.255.255.")
    rescue IP::AddressException => e
      assert(true, "init test #6")
    end

    assert(false, "init test #6") if ip

  end
  
  def test_accessor
    ip = IP::Address::IPv4.new("10.1.2.3")
    assert(ip.ip_address == "10.1.2.3", "accessor test #1")
    assert(ip.octets[0] == 10, "accessor test #2")
    assert(ip.octets[3] == 3, "accessor test #3")
    assert(ip.octets[4] == nil, "accessor test #4")
    
    assert(ip.octet(1) == ip[1] && ip[1] == 1, "accessor test #5")

    oct = nil

    begin
      oct = ip[4]
    rescue IP::BoundaryException => e
      assert(true, "accessor test #6")
    end
    
    assert(false, "accessor test #6") if oct
  end

end

class UtilTest < Test::Unit::TestCase
  def name
    return "IP::Address::Util tests"
  end
  
  def test_pack_unpack
    address = "10.0.0.1"
    assert(IP::Address::Util.unpack(IP::Address::Util.pack(IP::Address::IPv4.new(address))).ip_address == address, "pack/unpack test")
  end
  
  def test_short_netmask
    ip = IP::Address::IPv4.new("255.255.255.255")
    assert(IP::Address::Util.short_netmask(ip) == 32, "Short Netmask Test #1")
    ip = IP::Address::IPv4.new("255.255.255.248")
    assert(IP::Address::Util.short_netmask(ip) == 29, "Short Netmask Test #2")
  end

  def test_long_netmask
    assert(IP::Address::Util.long_netmask_ipv4(32).ip_address == "255.255.255.255", "Long Netmask Test #1")
    assert(IP::Address::Util.long_netmask_ipv4(29).ip_address == "255.255.255.248", "Long Netmask Test #2")
  end

end
