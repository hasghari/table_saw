# frozen_string_literal: true

require 'fileutils'

module TableSaw
  class CreateDumpFile
    attr_reader :records, :file, :format

    FORMATS = {
      'copy' => TableSaw::Formats::Copy,
      'insert' => TableSaw::Formats::Insert
    }.freeze

    def initialize(records, output:, format:)
      @records = records
      @file = output
      @format = format
    end

    # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    def call
      FileUtils.rm_f(file)
      FileUtils.mkdir_p(File.dirname(file))

      alter_constraints_deferrability

      write_to_file <<~SQL
        BEGIN;

        SET statement_timeout = 0;
        SET lock_timeout = 0;
        SET client_encoding = 'UTF8';
        SET standard_conforming_strings = on;
        SET check_function_bodies = false;
        SET client_min_messages = warning;

        SET search_path = public, pg_catalog;
      SQL

      records.each do |name, table|
        defer_constraints(name)

        write_to_file <<~COMMENT
          --
          -- Data for Name: #{name}; Type: TABLE DATA
          --

        COMMENT

        formatter = FORMATS.fetch(format.fetch('type', 'copy'), TableSaw::Formats::Copy).new(name, options: format)

        Array(formatter.header).each { |line| write_to_file(line) }

        TableSaw::Connection.with do |conn|
          conn.copy_data "COPY (#{table.copy_statement}) TO STDOUT", formatter.coder do
            while (row = conn.get_copy_data)
              write_to_file formatter.dump_row(row)
            end
          end
        end

        Array(formatter.footer).each { |line| write_to_file(line) }
      end

      write_to_file 'COMMIT;'
      write_to_file "\n"

      refresh_materialized_views
      restart_sequences

      alter_constraints_deferrability keyword: 'NOT DEFERRABLE'
    end
    # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

    private

    def alter_constraints_deferrability(keyword: 'DEFERRABLE')
      records.each_key do |name|
        write_to_file <<~COMMENT
          --
          -- Alter Constraints for Name: #{name}; Type: #{keyword}
          --

        COMMENT

        TableSaw.information_schema.constraint_names[name].each do |constraint_name|
          write_to_file "ALTER TABLE #{name} ALTER CONSTRAINT #{constraint_name} #{keyword};"
        end
      end
    end

    def defer_constraints(name)
      write_to_file <<~COMMENT
        --
        -- Set Constraints for Name: #{name}; Type: DEFERRED
        --

      COMMENT

      TableSaw.information_schema.constraint_names[name].each do |constraint_name|
        write_to_file "SET CONSTRAINTS #{constraint_name} DEFERRED;"
      end
    end

    def refresh_materialized_views
      TableSaw::Queries::MaterializedViews.new.call.each do |view|
        write_to_file "refresh materialized view #{view};"
      end

      write_to_file "\n"
    end

    def restart_sequences
      TableSaw::Queries::SerialSequences.new.call.slice(*records.keys).each do |table, sequence|
        write_to_file <<~SQL
          select setval('#{sequence.name}', (select max(#{sequence.column}) from #{table}), true);
        SQL
      end

      write_to_file "\n"
    end

    def write_to_file(data)
      File.open(file, 'ab') { |f| f.puts(data) }
    end
  end
end
