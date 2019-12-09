# frozen_string_literal: true

module TableSaw
  module Queries
    class ExecuteInsertStatement
      attr_reader :statement, :row

      def initialize(statement, row)
        @statement = statement
        @row = row
      end

      def call
        "EXECUTE #{statement.name}(#{values});"
      end

      private

      def values
        TableSaw.schema_cache.columns(statement.table_name).zip(row)
          .map { |column, value| connection.quote(connection.type_cast_from_column(column, value)) }
          .join(', ')
      end

      def schema_cache
        TableSaw.schema_cache
      end

      def connection
        schema_cache.connection
      end
    end
  end
end
