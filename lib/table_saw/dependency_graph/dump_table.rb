# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class DumpTable
      attr_reader :context, :name, :partial, :ids

      def initialize(context:, name:, partial: true)
        @context = context
        @name = name
        @partial = partial
        @ids = Set.new
      end

      def copy_statement
        if partial
          "select * from #{name} where id in (#{ids.to_a.join(',')})"
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
        TableSaw::DependencyGraph::BelongsToDirectives.new(context, directive).call
      end

      def fetch_has_many(directive)
        TableSaw::DependencyGraph::HasManyDirectives.new(context, directive).call
      end
    end
  end
end
