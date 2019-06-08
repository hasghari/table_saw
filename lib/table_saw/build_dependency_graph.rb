# frozen_string_literal: true

require 'table_saw/connection'
require 'table_saw/queries/foreign_key_relationships'
require 'table_saw/queries/no_id_tables'

module TableSaw
  class BuildDependencyGraph
    attr_reader :manifest, :records

    def initialize(manifest)
      @manifest = manifest
      @records = Hash.new { |h, k| h[k] = Set.new }
    end

    def call
      manifest.tables.each_value do |table|
        perform_query(table.query).each do |row|
          add(table.name, row['id'])
        end
      end

      records
    end

    def add(table_name, id)
      return if id.nil? || records[table_name].include?(id)

      records[table_name].add id
      fetch_belongs_to_associations(table_name, id)
      fetch_has_many_associations(table_name, id)
    end

    def fetch_belongs_to_associations(table_name, id)
      associations = belongs_to[table_name]
      return if associations.nil? || associations.empty?

      perform_query(
        format('select %{columns} from %{table_name} where id = %{id}',
               columns: associations.keys.join(','), table_name: table_name, id: id)
      ).each do |row|
        associations.each do |from_column, to_table|
          add(to_table, row[from_column])
        end
      end
    end

    def fetch_has_many_associations(table_name, id)
      has_many.fetch(table_name, []).each do |table, column|
        next if tables_with_no_ids.include?(table)
        next unless has_many_mapping.fetch(table_name, []).include?(table)

        perform_query(
          format('select id from %{table} where %{column} = %{id}', table: table, column: column, id: id)
        ).each do |row|
          add(table, row['id'])
        end
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
