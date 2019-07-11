# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class DumpTable
      attr_reader :manifest, :name, :partial, :ids

      def initialize(manifest:, name:, partial: true)
        @manifest = manifest
        @name = name
        @partial = partial
        @ids = Set.new
      end

      def copy_statement
        if partial
          "select * from #{name} where #{primary_key} in (#{ids.to_a.join(',')})"
        else
          "select * from #{name}"
        end
      end

      def fetch_associations(directive)
        directive.ids = directive.ids - ids.to_a
        ids.merge(directive.ids)
        fetch_belongs_to(directive) + fetch_has_many(directive)
      end

      private

      def fetch_belongs_to(directive)
        TableSaw::DependencyGraph::BelongsToDirectives.new(directive).call
      end

      def fetch_has_many(directive)
        TableSaw::DependencyGraph::HasManyDirectives.new(manifest, directive).call
      end

      def primary_key
        TableSaw.information_schema.primary_keys[name]
      end
    end
  end
end
