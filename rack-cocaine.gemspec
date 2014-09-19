# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack-cocaine', __FILE__)

Gem::Specification.new do |s|
  s.name = 'rack-cocaine'
  s.version = RackCocaine::version
  s.homepage = 'https://github.com/fuCtor/rake-cocaine'
  s.licenses = %w(Ruby LGPLv3)

  s.authors = ['Alexey Shcherbakov']
  s.email   = ['schalexey@gmail.com']

  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extensions = []

  s.summary = 'Rake adapter for Cocaine'
  s.description = 'RakeCocaine is a adapter for load Rack application as Cocaine worker.'

  s.add_development_dependency 'rspec', '~> 0'

  s.add_runtime_dependency 'cocaine', '~> 0.11.2'

  s.require_paths = ["lib"]
end