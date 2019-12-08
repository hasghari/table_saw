# frozen_string_literal: true

module TableSaw
  module Queries
    class SerializeSqlInClause
      attr_reader :table_name, :column, :values

      def initialize(table_name, column, values)
        @table_name = table_name
        @column = column
        @values = values
      end

      def call
        "#{column} in (#{serialized_values.join(', ')})"
      end

      private

      def db_column
        TableSaw.schema_cache.columns_hash(table_name)[column]
      end

      def serialized_values
        values.map do |value|
          connection.quote(connection.type_cast_from_column(db_column, value))
        end
      end

      def connection
        TableSaw::Connection.adapter
      end
    end
  end
end
