# frozen_string_literal: true

module TableSaw
  module Queries
    class MaterializedViews
      QUERY = <<~SQL
        select matviewname from pg_matviews
        where schemaname IN (:schemas)
        order by matviewname
      SQL

      def call
        ApplicationRecord.connection.exec_query(query).map { |row| row['matviewname'] }
      end

      private

      def query
        ApplicationRecord.sanitize_sql_array([QUERY, schemas: TableSaw.configuration.schemas])
      end
    end
  end
end
