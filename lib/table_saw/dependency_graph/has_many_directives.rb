# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class HasManyDirectives
      attr_reader :context, :directive

      def initialize(context, directive)
        @context = context
        @directive = directive
      end

      def call
        valid_associations.map do |table, column|
          TableSaw::DependencyGraph::AddDirective.new(
            table, ids: query_result(table, column).map { |r| r['id'] }, partial: directive.partial?
          )
        end
      end

      private

      def associations
        context.has_many.fetch(directive.table_name, [])
      end

      def valid_associations
        associations.select do |table, _column|
          next false if directive.partial? && context.tables_with_no_ids.include?(table)

          context.has_many_mapping.fetch(directive.table_name, []).include?(table)
        end
      end

      def query_result(table, column)
        return [] unless directive.selectable?

        context.perform_query(
          format('select id from %{table} where %{column} in (%{ids})',
                 table: table, column: column, ids: directive.ids.join(','))
        )
      end
    end
  end
end
