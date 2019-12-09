# frozen_string_literal: true

require 'active_record'

require 'active_record/connection_adapters/abstract/connection_pool'
require 'active_record/connection_adapters/postgresql_adapter'

module TableSaw
  module Connection
    def self.with
      raise ArgumentError, 'requires a block' unless block_given?

      yield adapter.raw_connection
    end

    def self.exec(sql)
      TableSaw::Connection.with do |conn|
        conn.exec(sql)
      end
    end

    def self.adapter
      @adapter ||= begin
        config = TableSaw.configuration.connection
        conn = ::PG::Connection.new(config)
        ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.new(conn, nil, config, {})
      end
    end
  end
end
