# frozen_string_literal: true

require 'table_saw/foreign_key'

module TableSaw
  module Queries
    class ForeignKeyRelationships
      QUERY = <<~SQL
        select
          tc.constraint_name,
          tc.table_name as from_table,
          kcu.column_name as from_column,
          ccu.table_name as to_table,
          ccu.column_name as to_column
        from information_schema.table_constraints tc
          join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
          join information_schema.constraint_column_usage ccu on tc.constraint_name = ccu.constraint_name
        where tc.constraint_type = 'FOREIGN KEY'
          and tc.table_schema IN (:schemas)
      SQL

      def constraint_names
        @constraint_names ||= result.each_with_object(Hash.new { |h, k| h[k] = [] }) do |row, memo|
          memo[row['from_table']].push(row['constraint_name'])
        end
      end

      def foreign_keys
        @foreign_keys ||= result.map do |row|
          TableSaw::ForeignKey.new(name: row['constraint_name'],
                                   from_table: row['from_table'], from_column: row['from_column'],
                                   to_table: row['to_table'], to_column: row['to_column'])
        end
      end

      private

      def result
        @result ||= ApplicationRecord.connection.exec_query(query)
      end

      def query
        ApplicationRecord.sanitize_sql_array([QUERY, { schemas: TableSaw.configuration.schemas }])
      end
    end
  end
end
