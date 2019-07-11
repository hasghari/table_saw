# frozen_string_literal: true

module TableSaw
  module Queries
    class PrimaryKeys
      QUERY = <<~SQL
        select tc.table_name, kcu.column_name
        from information_schema.table_constraints tc
                 join information_schema.key_column_usage kcu using (constraint_schema, constraint_name)
        where tc.constraint_type = 'PRIMARY KEY';
      SQL

      def call
        TableSaw::Connection.exec(QUERY).each_with_object({}) do |row, memo|
          memo[row['table_name']] = row['column_name']
        end
      end
    end
  end
end
