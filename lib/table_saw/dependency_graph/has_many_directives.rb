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
            ids: query_result(table, column).map { |r| r[TableSaw.information_schema.primary_keys[table]] },
            partial: directive.partial?
          )
        end
      end

      private

      def associations
        TableSaw.information_schema.has_many.fetch(directive.table_name, [])
      end

      def valid_associations
        associations.select do |table, _column|
          next false if directive.partial? && !TableSaw.information_schema.primary_keys.key?(table)

          manifest.has_many_mapping.fetch(directive.table_name, []).include?(table)
        end
      end

      def query_result(table, column)
        return [] unless directive.selectable?

        TableSaw::Connection.exec(
          format('select %{primary_key} from %{table} where %{column} in (%{ids})',
                 primary_key: TableSaw.information_schema.primary_keys[table], table: table, column: column,
                 ids: directive.ids.join(','))
        )
      end
    end
  end
end
