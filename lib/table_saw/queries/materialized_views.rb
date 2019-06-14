# frozen_string_literal: true

module TableSaw
  module Queries
    class MaterializedViews
      def call
        TableSaw::Connection.with do |conn|
          conn.exec('select matviewname from pg_matviews order by matviewname').map { |row| row['matviewname'] }
        end
      end
    end
  end
end
