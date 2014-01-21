#
# IP - Collection of Tools to work with IP addresses
#
# Version:: 0.3.0
# Author:: Erik Hollensbe
# License:: MIT
# Contact:: erik@hollensbe.org
# Copyright:: Copyright (c) 2005-2006 Erik Hollensbe
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

class IP
  VERSION = "0.3.1"

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

end

$:.push(File.dirname(__FILE__))
require 'ip/address'
require 'ip/cidr'
require 'ip/range'
require 'ip/util'
$:.pop
