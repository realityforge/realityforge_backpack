# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name               = %q{backpack}
  s.version            = '0.1.0.dev'
  s.platform           = Gem::Platform::RUBY

  s.authors            = ['Peter Donald']
  s.email              = %q{peter@realityforge.org}

  s.homepage           = %q{https://github.com/realityforge/backpack}
  s.summary            = %q{Backpack manages GitHub organizations declaratively.}
  s.description        = %q{Backpack is a very simple tool that helps you manage GitHub organizations declaratively.}

  s.licenses           = ['Apache-2.0']

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {spec}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths      = %w(lib)

  s.rdoc_options       = %w(--line-numbers --inline-source --title backpack)

  s.add_dependency 'reality-core', '>= 1.8.0'
  s.add_dependency 'reality-model', '>= 1.2.0'
  s.add_dependency 'reality-belt', '>= 1.0.0'
  s.add_dependency(%q<octokit>, ['>= 4.13'])
  s.add_dependency(%q<netrc>, ['~> 0.11'])
  s.add_dependency(%q<travis>, ['= 1.8.8'])
end
