# frozen_string_literal: true

module TableSaw
  class InformationSchema
    %i(belongs_to constraint_names has_many).each do |method_name|
      define_method method_name do
        foreign_key_relationships.public_send method_name
      end
    end

    private

    def foreign_key_relationships
      @foreign_key_relationships ||= TableSaw::Queries::ForeignKeyRelationships.new
    end
  end
end
