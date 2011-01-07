# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fixture_background/version"

Gem::Specification.new do |s|
  s.name        = "fixture_background"
  s.version     = FixtureBackground::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thies C. Arntzen", "Norman Timmler"]
  s.email       = ["dev+fixture_background@tmp8.de"]
  s.homepage    = "https://github.com/tmp8/fixture_background"
  s.summary     = %q{Generate fixtures from factories _in_ you testcode to speedup test-runs}
  s.description = %q{Generate fixtures from factories _in_ you testcode to speedup test-runs}

#  s.rubyforge_project = "my_gem"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
