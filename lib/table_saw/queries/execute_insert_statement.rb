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
          .map { |column, value| quote_value(column, value) }
          .join(', ')
      end

      def quote_value(column, value)
        type = TableSaw.connection.lookup_cast_type_from_column(column)
        TableSaw.connection.quote(type.serialize(type.deserialize(value)))
      end
    end
  end
end
