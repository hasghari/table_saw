# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class BelongsToDirectives
      attr_reader :directive

      def initialize(directive)
        @directive = directive
      end

      def call
        associations.map do |from_column, to_table|
          TableSaw::DependencyGraph::AddDirective.new(to_table, ids: ids[from_column], partial: directive.partial?)
        end
      end

      private

      def associations
        TableSaw.information_schema.belongs_to.fetch(directive.table_name, {})
      end

      def ids
        @ids ||= associations.each_key.each_with_object({}) do |column, memo|
          memo[column] = query_result(column).map { |row| row[column] }
        end
      end

      def query_result(column)
        return [] unless directive.selectable?

        TableSaw::Connection.exec(
          format(
            'select distinct %{column} from %{table_name} where %{clause} and %{column} is not null',
            primary_key: directive.primary_key, column: column, table_name: directive.table_name,
            clause: TableSaw::Queries::SerializeSqlInClause.new(directive.table_name, column, directive.ids).call
          )
        )
      end
    end
  end
end
