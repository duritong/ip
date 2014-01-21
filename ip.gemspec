$LOAD_PATH.unshift("lib")
require "ip"

Gem::Specification.new "ip", IP::VERSION do |s|
  s.author = "Erik Hollensbe"
  s.email = "erik@hollensbe.org"
  s.summary = "Ruby classes to work with IP address, ranges, and netmasks"
  s.files = `git ls-files lib`.split($/)
  s.rubyforge_project = 'ip-address'
  s.homepage = "http://github.com/erikh/ip"
  s.license = "BSD"
end
