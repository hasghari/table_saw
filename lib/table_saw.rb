# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/string'

require 'table_saw/configuration'
require 'table_saw/dependency_graph'
require 'table_saw/information_schema'
require 'table_saw/manifest'
require 'table_saw/queries'
require 'table_saw/formats'
require 'table_saw/variable_interpolation'

module TableSaw
  def self.configuration
    @configuration ||= TableSaw::Configuration.new
  end

  def self.configure(args = {})
    if block_given?
      yield configuration
    else
      args.each do |key, value|
        configuration.public_send("#{key}=", value)
      end
    end
  end

  def self.information_schema
    @information_schema ||= TableSaw::InformationSchema.new
  end

  def self.schema_cache
    connection.schema_cache
  end

  def self.connection_pool
    ActiveRecord::Base.connection_pool
  end

  # :nocov:
  def self.connection
    if ActiveRecord.gem_version < Gem::Version.new('7.2.0.rc1')
      connection_pool.connection
    else
      connection_pool.lease_connection
    end
  end
  # :nocov:
end
