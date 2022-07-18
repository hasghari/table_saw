# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class BuildHasManyQuery
      QUERY = <<~SQL.squish
        select %{primary_key} from %{table} where %{clause} and %{polymorphic}
      SQL

      attr_reader :manifest, :directive, :foreign_key

      def initialize(manifest, directive, foreign_key)
        @manifest = manifest
        @directive = directive
        @foreign_key = foreign_key
      end

      def call
        build_base_query
          .then { |query| append_scope(query) }
          .then { |query| append_limit(query) }
      end

      private

      # rubocop:disable Metrics/AbcSize
      def build_base_query
        format(QUERY, primary_key: TableSaw.primary_key(foreign_key.from_table),
                      table: foreign_key.from_table,
                      clause: TableSaw::Queries::SerializeSqlInClause.new(foreign_key.from_table,
                                                                          foreign_key.column.primary_key,
                                                                          directive.ids).call,
                      polymorphic: foreign_key.type_condition)
      end
      # rubocop:enable Metrics/AbcSize

      def append_scope(query)
        return query unless has_many&.scope

        [query, has_many.scope].join(' and ')
      end

      def append_limit(query)
        return query unless has_many&.limit

        [query, "limit #{has_many.limit}"].join(' ')
      end

      def has_many
        directive.has_many[foreign_key.from_table] ||
          manifest.has_many.fetch(directive.table_name, {})[foreign_key.from_table]
      end
    end
  end
end
