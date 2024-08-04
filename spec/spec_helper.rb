# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'active_record'
require 'scenic'
require 'combustion'
Combustion.initialize! :active_record

require 'bundler/setup'
require 'database_cleaner/active_record'
require 'table_saw'

require 'pry'

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
