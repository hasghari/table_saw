# frozen_string_literal: true

module TableSaw
  class Associations
    attr_reader :manifest

    def initialize(manifest)
      @manifest = manifest
    end

    def belongs_to
      @belongs_to ||= foreign_keys.each_with_object(Hash.new { |h, k| h[k] = Set.new }) do |fk, memo|
        memo[fk.from_table].add(fk)
      end
    end

    def has_many
      @has_many ||= foreign_keys.each_with_object(Hash.new { |h, k| h[k] = Set.new }) do |fk, memo|
        memo[fk.to_table].add(fk)
      end
    end

    private

    def foreign_keys
      @foreign_keys ||= manifest_foreign_keys + schema_foreign_keys
    end

    def manifest_foreign_keys
      manifest.foreign_keys.map do |fk|
        TableSaw::ForeignKey.new(from_table: fk['from_table'], from_column: fk['from_column'],
                                 to_table: fk['to_table'], to_column: fk['to_column'])
      end
    end

    def schema_foreign_keys
      TableSaw.information_schema.foreign_key_relationships.foreign_keys
    end
  end
end
