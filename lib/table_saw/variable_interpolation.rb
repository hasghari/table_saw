# frozen_string_literal: true

module TableSaw
  class VariableInterpolation
    def self.call(variables)
      new(variables).call
    end

    attr_reader :input

    def initialize(input)
      @input = input
    end

    def call
      input.transform_values do |value|
        next value unless value.is_a?(String)

        interpolate_variables(value, input)
      end
    end

    private

    def interpolate_variables(string, variables)
      string.gsub(/%{(\w+)}/) do |match|
        variable_name = ::Regexp.last_match(1)
        if variables.key?(variable_name)
          nested_value = interpolate_variables(variables[variable_name], variables)
          interpolate_variables(nested_value, variables)
        else
          match
        end
      end
    end
  end
end
