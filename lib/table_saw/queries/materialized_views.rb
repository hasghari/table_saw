# frozen_string_literal: true

require 'table_saw/connection'

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
