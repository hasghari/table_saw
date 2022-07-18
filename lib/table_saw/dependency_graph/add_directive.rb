# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class AddDirective
      attr_reader :table_name, :partial, :has_many
      attr_accessor :ids

      def initialize(table_name, ids: [], partial: true, has_many: {})
        @table_name = table_name
        @ids = ids
        @partial = partial
        @has_many = has_many
      end

      alias partial? partial

      def selectable?
        partial? && Array(ids).size.positive?
      end

      def queryable?
        !partial || selectable?
      end

      def primary_key
        TableSaw.primary_key(table_name)
      end
    end
  end
end
