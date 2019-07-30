# frozen_string_literal: true

module TableSaw
  module Queries
    class ForeignKeyRelationships
      QUERY = <<~SQL
        select
          tc.table_name as from_table,
          kcu.column_name as from_column,
          ccu.table_name as to_table,
          ccu.column_name as to_column
        from information_schema.table_constraints tc
          join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
          join information_schema.constraint_column_usage ccu on tc.constraint_name = ccu.constraint_name
        where tc.constraint_type = 'FOREIGN KEY'
      SQL

      def belongs_to
        @belongs_to ||= result.each_with_object(Hash.new { |h, k| h[k] = {} }) do |row, memo|
          memo[row['from_table']][row['from_column']] = row['to_table']
        end
      end

      def has_many
        @has_many ||= result.each_with_object(Hash.new { |h, k| h[k] = [] }) do |row, memo|
          memo[row['to_table']].push([row['from_table'], row['from_column']])
        end
      end

      private

      def result
        @result ||= TableSaw::Connection.exec(QUERY)
      end
    end
  end
end
