# frozen_string_literal: true

require 'table_saw/queries/table_columns'

module TableSaw
  class CreateDumpFile
    attr_reader :records, :file

    def initialize(records, file = 'psql.dump')
      @records = records
      @file = file
    end

    # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    def call
      write_to_file <<~SQL
        BEGIN;

        SET session_replication_role = replica;
        SET statement_timeout = 0;
        SET lock_timeout = 0;
        SET client_encoding = 'UTF8';
        SET standard_conforming_strings = on;
        SET check_function_bodies = false;
        SET client_min_messages = warning;

        SET search_path = public, pg_catalog;
      SQL

      records.each do |name, ids|
        write_to_file <<~COMMENT
          --
          -- Data for Name: #{name}; Type: TABLE DATA
          --

        COMMENT

        write_to_file <<~SQL
          COPY #{name} (#{quoted_columns(name)}) FROM STDIN;
        SQL

        TableSaw::Connection.with do |conn|
          conn.copy_data "COPY (select * from #{name} where id in (#{ids.to_a.join(',')})) TO STDOUT" do
            while (row = conn.get_copy_data)
              write_to_file(row)
            end
          end
        end

        write_to_file('\.')
        write_to_file("\n")
      end

      write_to_file 'COMMIT;'
    end
    # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

    private

    def write_to_file(data)
      File.open(file, 'ab') { |f| f.puts(data) }
    end

    def quoted_columns(table)
      TableSaw::Queries::TableColumns.new(table).call.map { |c| "\"#{c}\"" }.join(', ')
    end
  end
end
