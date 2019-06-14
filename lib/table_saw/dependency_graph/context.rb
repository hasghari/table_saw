# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class Context
      attr_reader :manifest

      def initialize(manifest)
        @manifest = manifest
      end

      def belongs_to
        foreign_key_relationships.belongs_to
      end

      # rubocop:disable Naming/PredicateName
      def has_many
        foreign_key_relationships.has_many
      end

      def has_many_mapping
        @has_many_mapping ||= manifest.tables.transform_values(&:has_many)
      end

      # rubocop:enable Naming/PredicateName

      def foreign_key_relationships
        @foreign_key_relationships ||= TableSaw::Queries::ForeignKeyRelationships.new
      end

      def tables_with_no_ids
        @tables_with_no_ids ||= TableSaw::Queries::NoIdTables.new.call
      end

      def perform_query(sql)
        TableSaw::Connection.with do |conn|
          conn.exec(sql)
        end
      end
    end
  end
end
