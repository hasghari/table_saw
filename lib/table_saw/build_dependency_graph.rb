# frozen_string_literal: true

require 'table_saw/connection'
require 'table_saw/queries/foreign_key_relationships'
require 'table_saw/queries/no_id_tables'

module TableSaw
  class BuildDependencyGraph
    attr_reader :manifest, :records

    def initialize(manifest)
      @manifest = manifest
      @records = Hash.new { |h, k| h[k] = [] }
    end

    def call
      manifest.tables.each_value do |table|
        add(table.name, perform_query(table.query).map { |row| row['id'] })
      end

      records
    end

    def add(table_name, ids)
      return if ids.empty?

      ids_to_add = ids - records[table_name]
      return if ids_to_add.empty?

      records[table_name].concat ids_to_add
      fetch_belongs_to_associations(table_name, ids_to_add)
      fetch_has_many_associations(table_name, ids_to_add)
    end

    # rubocop:disable Metrics/AbcSize
    def fetch_belongs_to_associations(table_name, ids)
      associations = belongs_to[table_name]
      return if associations.empty?

      rows = perform_query(
        format('select %{columns} from %{table_name} where id in (%{ids})',
               columns: associations.keys.join(','), table_name: table_name, ids: ids.join(','))
      )

      values = rows.each_with_object(Hash.new { |h, k| h[k] = Set.new }) do |row, memo|
        associations.each_key { |key| memo[key].add row[key] unless row[key].nil? }
      end

      associations.each { |from_column, to_table| add to_table, values[from_column].to_a }
    end
    # rubocop:enable Metrics/AbcSize

    def fetch_has_many_associations(table_name, ids)
      has_many.fetch(table_name, []).each do |table, column|
        next if tables_with_no_ids.include?(table)
        next unless has_many_mapping.fetch(table_name, []).include?(table)

        rows = perform_query(
          format('select id from %{table} where %{column} in (%{ids})',
                 table: table, column: column, ids: ids.join(','))
        )

        add(table, rows.map { |row| row['id'] })
      end
    end

    private

    def perform_query(sql)
      TableSaw::Connection.with do |conn|
        conn.exec(sql)
      end
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
  end
end
