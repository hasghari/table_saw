# frozen_string_literal: true

require 'table_saw/configuration'
require 'table_saw/connection'
require 'table_saw/dependency_graph'
require 'table_saw/information_schema'
require 'table_saw/manifest'
require 'table_saw/queries'
require 'table_saw/formats'

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
    TableSaw::Connection.adapter.schema_cache
  end
end
