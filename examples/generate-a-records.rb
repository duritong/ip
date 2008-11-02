#!/usr/bin/env ruby
#
# Generate a set of A records suitable for inclusion in a
# zone.
#
# Takes two IP addresses as a range to generate.
# 

begin
  require 'rubygems'
rescue LoadError => e
end

require 'ip'

if !ARGV[0] or !ARGV[1]
  $stderr.puts "usage: #{File.basename($0)} <start ip> <end ip>"
  exit -1
end

$fmt = "%15.15s    IN A    %15.15s"

IP::Range[ARGV[0], ARGV[1]].each do |ip|
  hostname = ip.ip_address.gsub(/\./, "-")
  puts ($fmt % [hostname, ip.ip_address])
end
