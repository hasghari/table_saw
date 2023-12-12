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

  def self.primary_keys(manifest, table_name)
    override_primary_key = look_for_primary_key(manifest, table_name)

    if override_primary_key.present?
      override_primary_key
    else
      schema_primary_keys = TableSaw.primary_keys(manifest, table_name)

      raise ArgumentError, 'a primary_key: must be specified for foreign tables' unless schema_primary_keys.present?

      schema_primary_keys
    end
  end

  def self.look_for_primary_key(manifest, table_name)
    suggested_primary_key = nil

    manifest.tables.each_value do |table|
      if table.name == table_name && table.primary_key.present?
        suggested_primary_key = table.primary_key
        next
      end
    end

    suggested_primary_key
  end

  private_class_method :look_for_primary_key
end
