#
# Please see the COPYING file in the source distribution for copyright information.
# 

begin
    require 'rubygems'
    gem 'test-unit'
rescue LoadError
end

$:.unshift 'lib'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'ip'

task :default => [ :dist ]

#
# Tests
#

Rake::TestTask.new do |t|
    t.libs << 'lib'
    t.test_files = FileList['test/test*.rb']
    t.verbose = true 
end

#
# Distribution
#

task :dist      => [:test, :repackage, :gem, :rdoc]
task :distclean => [:clobber_package, :clobber_rdoc]
task :clean     => [:distclean]

#
# Documentation
#

Rake::RDocTask.new do |rd|
    rd.rdoc_dir = "rdoc"
    rd.main = "IP"
    rd.rdoc_files.include("./lib/**/*.rb")
    rd.options = %w(-ap)
end

#
# Packaging
# 

spec = Gem::Specification.new do |s|
    s.name = "ip"
    s.version = IP::VERSION
    s.author = "Erik Hollensbe"
    s.email = "erik@hollensbe.org"
    s.summary = "Ruby classes to work with IP address, ranges, and netmasks"
    s.has_rdoc = true
    s.files = Dir['examples/*.rb'] + Dir['lib/*.rb'] + Dir['test/*.rb'] + Dir['lib/ip/*.rb']
    s.rubyforge_project = 'ip-address'
end

Rake::GemPackageTask.new(spec) do |s|
end

Rake::PackageTask.new(spec.name, spec.version) do |p|
    p.need_tar_gz = true
    p.need_zip = true
    p.package_files.include("./Rakefile")
    p.package_files.include("./examples/**/*.rb")
    p.package_files.include("./lib/**/*.rb")
    p.package_files.include("./test/**/*")
end
