# frozen_string_literal: true

module TableSaw
  module Queries
    class NoIdTables
      QUERY = <<~SQL
        select t.table_name
        from information_schema.tables t left outer join information_schema.table_constraints tc
            on t.table_name = tc.table_name and tc.constraint_type = 'PRIMARY KEY'
        where t.table_schema = 'public' and table_type = 'BASE TABLE' and tc.table_name IS NULL
      SQL

      def call
        TableSaw::Connection.with do |conn|
          conn.exec(QUERY)
        end
      end
    end
  end
end
