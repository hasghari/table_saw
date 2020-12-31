# frozen_string_literal: true

module TableSaw
  class ForeignKey
    class Column
      REGEX = /(\w+)(?::(\w+)\((\w+)\))?/.freeze

      attr_reader :value

      def initialize(value)
        @value = value
      end

      def primary_key
        value[REGEX, 1]
      end

      def type_condition
        polymorphic? ? "#{type_column} = '#{type_value}'" : '1 = 1'
      end

      private

      def type_column
        value[REGEX, 2]
      end

      def type_value
        value[REGEX, 3]
      end

      def polymorphic?
        !(type_column.nil? || type_value.nil?)
      end
    end

    attr_reader :name, :from_table, :from_column, :to_table, :to_column

    def initialize(from_table:, from_column:, to_table:, to_column:, name: nil)
      @name = name
      @from_table = from_table
      @from_column = from_column
      @to_table = to_table
      @to_column = to_column
    end

    def type_condition
      @type_condition ||= column.type_condition
    end

    def column
      @column ||= Column.new(from_column)
    end

    def eql?(other)
      hash == other.hash
    end

    def hash
      [from_table, from_column, to_table, to_column].hash
    end
  end
end
