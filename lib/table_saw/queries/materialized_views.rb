# frozen_string_literal: true

module TableSaw
  module Queries
    class MaterializedViews
      QUERY = 'select matviewname from pg_matviews order by matviewname'

      def call
        TableSaw::Connection.exec(QUERY).map { |row| row['matviewname'] }
      end
    end
  end
end
