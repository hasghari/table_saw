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
          format 'select * from %{name} where %{clause}',
                 name: name, clause: TableSaw::Queries::SerializeSqlInClause.new(name, primary_key, ids.to_a).call

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
        TableSaw::DependencyGraph::BelongsToDirectives.new(manifest, directive).call
      end

      def fetch_has_many(directive)
        TableSaw::DependencyGraph::HasManyDirectives.new(manifest, directive).call
      end

      def primary_key
        TableSaw.primary_key(name)
      end
    end
  end
end
