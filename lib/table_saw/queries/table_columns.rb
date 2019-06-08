# frozen_string_literal: true

require 'table_saw/connection'

module TableSaw
  module Queries
    class TableColumns
      QUERY = <<~SQL
        select attname as colname
        from pg_catalog.pg_attribute
        where
                attrelid = $1::regclass
          and attnum > 0
          and attisdropped = false
        order by attnum
      SQL

      attr_reader :table

      def initialize(table)
        @table = table
      end

      def call
        TableSaw::Connection.with { |conn| conn.exec_params(QUERY, [table]) }.map { |r| r['colname'] }
      end
    end
  end
end
