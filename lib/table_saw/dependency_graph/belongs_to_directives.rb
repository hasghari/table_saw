# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class BelongsToDirectives
      QUERY = <<~SQL
        select distinct %{column} from %{table_name} where %{clause} and %{column} is not null and %{polymorphic}
      SQL

      attr_reader :manifest, :directive

      def initialize(manifest, directive)
        @manifest = manifest
        @directive = directive
      end

      def call
        associations.map do |fk|
          TableSaw::DependencyGraph::AddDirective.new(fk.to_table, ids: ids[fk.column.primary_key],
                                                                   partial: directive.partial?)
        end
      end

      private

      def associations
        manifest.associations.belongs_to.fetch(directive.table_name, Set.new)
      end

      def ids
        @ids ||= associations.each_with_object({}) do |fk, memo|
          memo[fk.column.primary_key] = query_result(fk).map { |row| row[fk.column.primary_key] }
        end
      end

      # rubocop:disable Metrics/AbcSize
      def query_result(foreign_key)
        return [] unless directive.selectable?

        TableSaw.connection.exec_query(
          format(QUERY, column: foreign_key.column.primary_key, table_name: directive.table_name,
                        clause: TableSaw::Queries::SerializeSqlInClause.new(directive.table_name,
                                                                            directive.primary_key,
                                                                            directive.ids).call,
                        polymorphic: foreign_key.type_condition)
        )
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
