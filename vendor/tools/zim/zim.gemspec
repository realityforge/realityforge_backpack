# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name               = %q{zim}
  s.version            = '0.1.0.dev'
  s.platform           = Gem::Platform::RUBY

  s.authors            = ['Peter Donald']
  s.email              = %q{peter@realityforge.org}

  s.homepage           = %q{https://github.com/realityforge/zim}
  s.summary            = %q{Zim automates manipulation of source code repositories.}
  s.description        = %q{Zim is a really simple tool used to perform mechanical transformation of multiple code bases.}

  s.rubyforge_project  = %q{zim}
  s.licenses           = ['Apache-2.0']

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {spec}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths      = %w(lib)

  s.rdoc_options       = %w(--line-numbers --inline-source --title zim)

  s.add_dependency 'reality-core', '>= 1.8.0'
  s.add_dependency 'reality-model', '>= 1.2.0'
  s.add_dependency 'reality-belt', '>= 1.0.0'
  s.add_dependency 'zapwhite', '= 2.8.0'
end
