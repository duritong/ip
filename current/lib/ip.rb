#
# IP - Collection of Tools to work with IP addresses
#
# Version:: 0.1.0
# Author:: Erik Hollensbe
# License:: BSD
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
#
#--
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
#++

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

end

$:.push(File.dirname(__FILE__))
require 'ip/address'
require 'ip/cidr'
require 'ip/range'
require 'ip/util'
$:.pop
