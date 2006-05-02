#!/usr/bin/env ruby
#
# given two CIDR formatted addresses, check for overlaps.
#
# Takes either IPv6 or IPv4.
#

begin
  require 'rubygems'
rescue LoadError => e
end

require 'ip'

if !ARGV[0] or !ARGV[1]
  $stderr.puts "usage: #{File.basename($0)} <cidr> <cidr>"
  exit -1
end

if IP::CIDR.new(ARGV[0]).overlaps? IP::CIDR.new(ARGV[1])
  $stderr.puts "These address ranges overlap."
  exit 1
else
  $stderr.puts "No overlaps"
  exit 0
end
