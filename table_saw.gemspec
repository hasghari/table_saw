# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'table_saw/version'

Gem::Specification.new do |spec|
  spec.name          = 'table_saw'
  spec.version       = TableSaw::VERSION
  spec.authors       = ['Hamed Asghari']
  spec.email         = ['hasghari@gmail.com']

  spec.summary       = 'Create a postgres dump file from a subset of tables'
  spec.homepage      = 'https://github.com/hasghari/table_saw'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = ['table-saw']
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 5.2'
  spec.add_dependency 'pg'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'combustion', '~> 1.3'
  spec.add_development_dependency 'database_cleaner', '~> 1.7'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.33'
  spec.add_development_dependency 'scenic', '~> 1.5'
  spec.add_development_dependency 'simplecov', '~> 0.16'
end
