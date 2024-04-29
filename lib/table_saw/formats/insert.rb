# frozen_string_literal: true

module TableSaw
  module Formats
    class Insert < TableSaw::Formats::Base
      def header
        prepared_statement.sql
      end

      def footer
        "\n"
      end

      def dump_row(row)
        TableSaw::Queries::ExecuteInsertStatement.new(prepared_statement, row).call
      end

      def coder
        PG::TextDecoder::CopyRow.new
      end

      private

      def prepared_statement
        @prepared_statement ||= TableSaw::Queries::PreparedInsertStatement.new(table_name, options:).call
      end
    end
  end
end
