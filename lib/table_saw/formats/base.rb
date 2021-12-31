# frozen_string_literal: true

module TableSaw
  module Formats
    class Base
      attr_reader :table_name, :options

      def initialize(table_name, options: {})
        @table_name = table_name
        @options = options
      end

      def header
        raise NotImplementedError
      end

      def footer
        raise NotImplementedError
      end

      def dump_row(_row)
        raise NotImplementedError
      end

      def coder = nil
    end
  end
end
