# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sod/version"

Gem::Specification.new do |s|
  s.name        = "sod"
  s.version     = Sod::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Sofaer"]
  s.email       = ["msofaer@pivotallabs.com"]
  s.homepage    = ""
  s.summary     = %q{sod runs your chef recipes on remote servers}
  s.description = %q{sod is a gem for going from a blank OS to a fully deployed system.  It installs ruby and chef, and runs your chef scripts.}

  s.rubyforge_project = "sod"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
