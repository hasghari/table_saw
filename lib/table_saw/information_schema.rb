# frozen_string_literal: true

module TableSaw
  class InformationSchema
    def constraint_names
      foreign_key_relationships.constraint_names
    end

    def foreign_key_relationships
      @foreign_key_relationships ||= TableSaw::Queries::ForeignKeyRelationships.new
    end
  end
end
