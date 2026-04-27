# frozen_string_literal: true

module TableSaw
  module Queries
    class SerialSequences
      QUERY = <<~SQL
        select
          pg_get_serial_sequence(kcu.table_name, kcu.column_name) as sequence,
          kcu.table_name as "table",
          kcu.column_name as "column"
        from information_schema.key_column_usage as kcu
                 inner join information_schema.table_constraints as tc
                            on tc.constraint_name = kcu.constraint_name
        where tc.constraint_type = 'PRIMARY KEY'
          and kcu.table_schema IN (:schemas)
          and pg_get_serial_sequence(kcu.table_name, kcu.column_name) is not null
      SQL

      SerialSequence = Struct.new(:name, :table, :column)

      def call
        ApplicationRecord.connection.exec_query(query).each_with_object({}) do |row, memo|
          memo[row['table']] = SerialSequence.new(row['sequence'], row['table'], row['column'])
        end
      end

      private

      def query
        ApplicationRecord.sanitize_sql_array([QUERY, { schemas: TableSaw.configuration.schemas }])
      end
    end
  end
end
