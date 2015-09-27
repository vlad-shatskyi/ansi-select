# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ansi/selector/version'

Gem::Specification.new do |spec|
  spec.name          = "ansi-selector"
  spec.version       = Ansi::Selector::VERSION
  spec.authors       = ["Volodymyr Shatskyi"]
  spec.email         = ["shockone89@gmail.com"]

  spec.summary       = %q{Simple, not full-screen, ncurses-like TUI selector}
  spec.description   = %q{This gem allows you to select an array element (where an array is arbitrary input) with a pretty text user interface.}
  spec.homepage      = "https://github.com/shockone/ansi-selector"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
