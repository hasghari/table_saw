# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class AddDirective
      attr_reader :table_name, :partial
      attr_accessor :ids

      def initialize(table_name, ids: [], partial: true)
        @table_name = table_name
        @ids = ids
        @partial = partial
      end

      alias partial? partial

      def selectable?
        partial? && Array(ids).size.positive?
      end

      def queryable?
        !partial || selectable?
      end
    end
  end
end
