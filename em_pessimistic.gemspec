# -*- encoding: utf-8 -*-
require File.join("lib/em_pessimistic/version")

Gem::Specification.new do |s|
  s.name        = "em_pessimistic"
  s.version     = EMPessimistic::VERSION
  s.authors     = ["Christian Johansen"]
  s.email       = ["christian@gitorious.org"]
  s.homepage    = "http://gitorious.org/gitorious/em_pessimistic"
  s.summary     = %q{popen with stderr and DeferrableChildProcess with errback for EventMachine}
  s.description = %q{EventMachine's built-in popen does not provide access to stderr. Likewise, it's DeferrableChildProcess does not use an errback for when the process fails. This gem fixes both of those mistakes.}

  s.rubyforge_project = "em_pessimistic"

  s.add_dependency "eventmachine", "~>0.12"

  s.add_development_dependency "minitest", "~> 2.0"
  s.add_development_dependency "em-minitest-spec", "~> 1.1"
  s.add_development_dependency "rake", "~> 0.9"

  s.files         = `git ls-files -- lib/*`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ["lib"]
end
