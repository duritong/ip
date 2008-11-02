#!/usr/bin/env ruby
#
# Checks if a given IP address exists in a subnet.
#
# Takes either IPv6 or IPv4.
#

begin
  require 'rubygems'
rescue LoadError => e
end

require 'ip'

if !ARGV[0] or !ARGV[1]
  $stderr.puts "usage: #{File.basename($0)} <cidr> <ip>"
  exit -1
end

if IP::CIDR.new(ARGV[0]).includes? IP::Address::Util.string_to_ip(ARGV[1])
  $stderr.puts "IP #{ARGV[1]} exists in the #{ARGV[0]} subnet"
  exit 0
else
  $stderr.puts "IP #{ARGV[1]} does not exist in the #{ARGV[0]} subnet"
  exit 1
end

