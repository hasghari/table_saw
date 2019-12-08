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
        valid_associations.map do |table, column|
          TableSaw::DependencyGraph::AddDirective.new(
            table,
            ids: query_result(table, column).map { |r| r[TableSaw.schema_cache.primary_keys(table)] },
            partial: directive.partial?
          )
        end
      end

      private

      def associations
        TableSaw.information_schema.has_many.fetch(directive.table_name, [])
      end

      # rubocop:disable Metrics/AbcSize
      def valid_associations
        associations.select do |table, _column|
          next false if directive.partial? && TableSaw.schema_cache.primary_keys(table).nil?
          next true if directive.has_many.include?(table)

          manifest.has_many.fetch(directive.table_name, []).include?(table)
        end
      end
      # rubocop:enable Metrics/AbcSize

      def query_result(table, column)
        return [] unless directive.selectable?

        TableSaw::Connection.exec(
          format(
            'select %{primary_key} from %{table} where %{clause}',
            primary_key: TableSaw.schema_cache.primary_keys(table), table: table,
            clause: TableSaw::Queries::SerializeSqlInClause.new(table, column, directive.ids).call
          )
        )
      end
    end
  end
end
