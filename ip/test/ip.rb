require 'test/unit'
load 'lib/ip.rb'

class CIDRTest < Test::Unit::TestCase

  def name
    return "IP::CIDR tests"
  end

  def test_init
    a = nil
    begin
      IP::CIDR.new(Hash.new)
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "data types test #1")
    
    begin
      IP::CIDR.new("10.0.0.1")
      a = false
    rescue IP::AddressException => e
      a = true
    end
    
    assert(a, "data types test #2")
    
    begin
      IP::CIDR.new("10.0.0.1/")
      a = false
    rescue IP::AddressException => e
      a = true
    end
    
    assert(a, "data types test #3")
    
    begin
      IP::CIDR.new("10.0.0.1/asdf/32")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "data type test #4")
    
    begin
      IP::CIDR.new("10.0.0.1/foomatic_wootmaster")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "data types test #5")

    begin
      IP::CIDR.new("foomatic_wootmaster/32")
      a = false
    rescue IP::AddressException => e
      a = true
    end
    
    assert(a, "data types test #6")

    begin
      IP::CIDR.new("10.0.0.1/255")
      a = false
    rescue IP::AddressException => e
      a = true
    end

    assert(a, "data types test #7")

    cidr = IP::CIDR.new("10.0.0.1/32")
    
    assert(cidr.ip.ip_address == "10.0.0.1", "data integrity test #1")
    assert(cidr.mask == 32, "data integrity test #2")
    assert(cidr.cidr == "10.0.0.1/32", "data integrity test #3")

    cidr = IP::CIDR.new("10.0.0.1/255.255.255.255")

    assert(cidr.ip.ip_address == "10.0.0.1", "data integrity test #4")
    assert(cidr.mask == 32, "data integrity test #5")
    assert(cidr.cidr == "10.0.0.1/255.255.255.255", "data integrity test #6")
  end

  def test_netmasks
    cidr = IP::CIDR.new("10.0.0.1/32")
    assert(cidr.short_netmask == 32, "netmask test #1")
    assert(cidr.long_netmask.ip_address == "255.255.255.255", "netmask test #2")
    
    cidr = IP::CIDR.new("10.0.0.1/255.255.255.241")
    assert(cidr.short_netmask == 29, "netmask test #3")
    assert(cidr.long_netmask.ip_address == "255.255.255.248", "netmask test #4")
  end

  def test_first_last
    cidr = IP::CIDR.new("10.0.0.2/24")
    assert(cidr.first_ip.ip_address == "10.0.0.0", "first/last test #1")
    assert(cidr.last_ip.ip_address == "10.0.0.255", "first/last test #2")
  end

  def test_range
    cidr = IP::CIDR.new("10.0.0.2/24")
    assert(cidr.range.find_all { |x| x.ip_address == "10.0.0.1" }.length == 1, "range test #1")
    assert(cidr.range.find_all { |x| x.ip_address == "10.0.1.0" }.length == 0, "range test #2")
  end

  def test_overlaps
    cidr = IP::CIDR.new("10.0.0.2/24")
    cidr2 = IP::CIDR.new("10.0.0.1/29")

    assert(cidr.overlaps?(cidr2), "overlaps test #1")

    cidr2 = IP::CIDR.new("10.0.0.1/16")

    assert(cidr2.overlaps?(cidr), "overlaps test #2")
    assert(cidr.overlaps?(cidr2), "overlaps test #3")
  end
end

class RangeTest < Test::Unit::TestCase
  def name
    return "IP::Range tests"
  end

  def test_range
    a = nil
    begin
      IP::Range["10.0.0.1", "10.0.0.2"]
      a = true
    rescue Exception => e
      a = false
    end
    
    assert(a, "data types test #1")
    
    begin
      IP::Range[IP::Address.new("10.0.0.1"), IP::Address.new("10.0.0.2")]
      a = true
    rescue Exception => e
      a = false
    end

    assert(a, "data types test #2")

    range = IP::Range["10.0.0.1", "10.0.0.10"]

    assert(range.find_all { |x| x.ip_address == "10.0.0.1" }.length == 1, "range check #1")
    assert(range.find_all { |x| x.ip_address == "10.0.0.10" }.length == 1, "range check #2")
    assert(range.find_all { |x| x.ip_address == "10.0.0.7" }.length == 1, "range check #3")
    assert(range.find_all { |x| x.ip_address == "10.0.0.11" }.length == 0, "range check #4")

  end

end

class AddressTest < Test::Unit::TestCase
  def name
    return "IP::Address tests"
  end

  def test_init
    ip = nil
    begin
      ip = IP::Address.new(Hash.new)
    rescue IP::AddressException => e
      assert(true, "init test #1")
    end

    assert(false, "init test #2") if ip

    ip = nil

    begin
      ip = IP::Address.new("asdf")
    rescue IP::AddressException => e
      assert(true, "init test #2")
    end

    assert(false, "init test #2") if ip
    ip = nil

    begin
      ip = IP::Address.new("0.0.0")
    rescue IP::AddressException => e
      assert(true, "init test #3")
    end

    assert(false, "init test #3") if ip
    ip = nil
    
    begin
      ip = IP::Address.new("256.255.255.255")
    rescue IP::AddressException => e
      assert(true, "init test #4")
    end

    assert(false, "init test #4") if ip
  end
  
  def test_accessor
    ip = IP::Address.new("10.1.2.3")
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
    assert(IP::Address::Util.unpack(IP::Address::Util.pack(IP::Address.new(address))).ip_address == address, "pack/unpack test")
  end
  
  def test_short_netmask
    ip = IP::Address.new("255.255.255.255")
    assert(IP::Address::Util.short_netmask(ip) == 32, "Short Netmask Test #1")
    ip = IP::Address.new("255.255.255.241")
    assert(IP::Address::Util.short_netmask(ip) == 29, "Short Netmask Test #2")
    
    nm = nil

    begin
      nm = IP::Address::Util.short_netmask(IP::Address.new("255.255.0.255"))
    rescue IP::BoundaryException => e
      assert(true, "Short Netmask BoundaryException Check #1")
    end

    assert(false, "Short Netmask BoundaryException Check #1") if nm
    
    nm = nil

    begin
      nm = IP::Address::Util.short_netmask(IP::Address.new("255.255.240.255"))
    rescue IP::BoundaryException => e
      assert(true, "Short Netmask BoundaryException check #2")
    end
    
    assert(false, "Short Netmask BoundaryException check #2") if nm
  end

  def test_long_netmask
    assert(IP::Address::Util.long_netmask(32).ip_address == "255.255.255.255", "Long Netmask Test #1")
    assert(IP::Address::Util.long_netmask(29).ip_address == "255.255.255.248", "Long Netmask Test #2")
  end

  def test_binary_vector
    assert(IP::Address::Util.binary_vector(255).length == 8, "Binary Vector Test #1")
    assert(IP::Address::Util.binary_vector(240).find_all { |x| x == 1 }.length == 4, "Binary Vector Test #2")
    assert(IP::Address::Util.binary_vector(241).find_all { |x| x == 1 }.length == 5, "Binary Vector Test #3")
    assert(IP::Address::Util.binary_vector(240)[0] == 1, "Binary Vector Test #4")
  end

end
