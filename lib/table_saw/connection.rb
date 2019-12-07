# frozen_string_literal: true

require 'pg'
require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'

module TableSaw
  module Connection
    def self.with
      raise ArgumentError, 'requires a block' unless block_given?

      yield raw
    end

    def self.raw
      @raw ||= PG::Connection.new(TableSaw.configuration.connection)
    end

    def self.exec(sql)
      TableSaw::Connection.with do |conn|
        conn.exec(sql)
      end
    end

    def self.adapter
      @adapter ||=
        ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.new(nil, nil, TableSaw.configuration.connection, {})
    end
  end
end
