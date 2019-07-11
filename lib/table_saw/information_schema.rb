# frozen_string_literal: true

module TableSaw
  class InformationSchema
    def belongs_to
      foreign_key_relationships.belongs_to
    end

    # rubocop:disable Naming/PredicateName
    def has_many
      foreign_key_relationships.has_many
    end
    # rubocop:enable Naming/PredicateName

    def primary_keys
      @primary_keys ||= TableSaw::Queries::PrimaryKeys.new.call
    end

    private

    def foreign_key_relationships
      @foreign_key_relationships ||= TableSaw::Queries::ForeignKeyRelationships.new
    end
  end
end
