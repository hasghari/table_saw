# frozen_string_literal: true

require 'table_saw/version'
require 'table_saw/configuration'

module TableSaw
  def self.configuration
    @configuration ||= TableSaw::Configuration.new
  end

  def self.configure(args = {})
    if block_given?
      yield configuration
    else
      args.each do |key, value|
        configuration.public_send("#{key}=", value)
      end
    end
  end
end
