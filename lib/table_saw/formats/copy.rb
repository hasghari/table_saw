# frozen_string_literal: true

module TableSaw
  module Formats
    class Copy < TableSaw::Formats::Base
      def header
        "COPY #{table_name} (#{quoted_columns}) FROM STDIN;"
      end

      def footer
        ['\.', "\n"]
      end

      def dump_row(row)
        row
      end

      private

      def quoted_columns
        TableSaw.schema_cache.columns_hash(table_name)
          .each_key
          .map { |name| connection.quote_column_name(name) }
          .join(', ')
      end

      def connection
        TableSaw.schema_cache.connection
      end
    end
  end
end
