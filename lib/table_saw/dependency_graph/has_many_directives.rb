# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class HasManyDirectives
      QUERY = <<~SQL
        select %{primary_key} from %{table} where %{clause} and %{polymorphic}
      SQL

      attr_reader :manifest, :directive

      def initialize(manifest, directive)
        @manifest = manifest
        @directive = directive
      end

      def call
        valid_associations.map do |fk|
          TableSaw::DependencyGraph::AddDirective.new(
            fk.from_table,
            ids: query_result(fk).map { |r| r[TableSaw.schema_cache.primary_keys(fk.from_table)] },
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
          next false if directive.partial? && TableSaw.schema_cache.primary_keys(fk.from_table).nil?
          next true if directive.has_many.include?(fk.from_table)

          manifest.has_many.fetch(directive.table_name, []).include?(fk.from_table)
        end
      end

      def query_result(foreign_key)
        return [] unless directive.selectable?

        TableSaw::Connection.exec(
          format(QUERY, primary_key: TableSaw.schema_cache.primary_keys(foreign_key.from_table),
                        table: foreign_key.from_table,
                        clause: TableSaw::Queries::SerializeSqlInClause.new(foreign_key.from_table,
                                                                            foreign_key.column.primary_key,
                                                                            directive.ids).call,
                        polymorphic: foreign_key.type_condition)
        )
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
