# frozen_string_literal: true

module TableSaw
  module Queries
    class PreparedInsertStatement
      attr_reader :table_name, :options

      Statement = Struct.new(:name, :table_name, :sql)

      def initialize(table_name, options: {})
        @table_name = table_name
        @options = options
      end

      def call
        Statement.new(name, table_name, sql)
      end

      private

      def name
        "#{table_name}_insert_plan"
      end

      def sql
        "#{[prepare_statement, conflict_statement].compact.join(' ')};"
      end

      def column_types
        TableSaw.schema_cache.columns(table_name).map(&:sql_type_metadata).map(&:sql_type).join(', ')
      end

      def column_names
        TableSaw.schema_cache.columns(table_name)
          .map { |column| TableSaw.connection.quote_column_name(column.name) }
          .join(', ')
      end

      def values_clause
        1.upto(TableSaw.schema_cache.columns(table_name).size).map { |i| "$#{i}" }.join(', ')
      end

      def prepare_statement
        <<~SQL.squish
          PREPARE #{name} (#{column_types}) AS INSERT INTO #{table_name} (#{column_names}) VALUES (#{values_clause})
        SQL
      end

      def conflict_statement
        return unless options['ignore_conflict'] == 'true'

        'ON CONFLICT DO NOTHING'
      end
    end
  end
end
