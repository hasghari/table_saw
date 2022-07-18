# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class HasManyDirectives
      attr_reader :manifest, :directive

      def initialize(manifest, directive)
        @manifest = manifest
        @directive = directive
      end

      def call
        valid_associations.map do |fk|
          TableSaw::DependencyGraph::AddDirective.new(
            fk.from_table,
            ids: query_result(fk).map { |r| r[TableSaw.primary_key(fk.from_table)] },
            partial: directive.partial?
          )
        end
      end

      private

      def associations
        manifest.associations.has_many.fetch(directive.table_name, Set.new)
      end

      # rubocop:disable Metrics/AbcSize
      def valid_associations
        associations.select do |fk|
          next false if directive.partial? && TableSaw.primary_key(fk.from_table).nil?
          next true if directive.has_many.key?(fk.from_table)

          manifest.has_many.fetch(directive.table_name, {}).key?(fk.from_table)
        end
      end
      # rubocop:enable Metrics/AbcSize

      def query_result(foreign_key)
        return [] unless directive.selectable?

        TableSaw::Connection.exec(
          TableSaw::DependencyGraph::BuildHasManyQuery.new(manifest, directive, foreign_key).call
        )
      end
    end
  end
end
