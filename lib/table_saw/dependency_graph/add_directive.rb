# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class AddDirective
      attr_reader :manifest, :table_name, :partial, :has_many
      attr_accessor :ids

      def initialize(manifest, table_name, ids: [], partial: true, has_many: {})
        @manifest = manifest
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
        TableSaw.primary_keys(manifest, table_name)
      end
    end
  end
end
