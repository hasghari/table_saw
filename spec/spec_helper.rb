# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'active_record'
require 'scenic'
require 'combustion'
Combustion.initialize! :active_record

require 'bundler/setup'
require 'database_cleaner'
require 'table_saw'

require 'pry'

db_config = if ActiveRecord.gem_version < Gem::Version.create('6.1.0')
              ActiveRecord::Base.connection_config
            else
              ActiveRecord::Base.connection_pool.db_config.configuration_hash
            end

TableSaw.configure(
  host: db_config[:host], dbname: db_config[:database], user: db_config[:username], password: db_config[:password]
)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Can't use transaction since our gem has no ActiveRecord dependency. ActiveRecord is only used for convenience in
  # setting up the test database via Combustion
  DatabaseCleaner.strategy = :truncation

  config.before { DatabaseCleaner.start }
  config.after { DatabaseCleaner.clean }
end
