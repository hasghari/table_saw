# frozen_string_literal: true

require 'pg'
require 'connection_pool'

module TableSaw
  module Connection
    def self.with
      raise ArgumentError, 'requires a block' unless block_given?

      pool.with { |conn| yield conn }
    end

    def self.pool
      @pool ||= ConnectionPool.new(size: 2) { PG::Connection.new(TableSaw.configuration.connection) }
    end

    def self.exec(sql)
      TableSaw::Connection.with do |conn|
        conn.exec(sql)
      end
    end
  end
end
