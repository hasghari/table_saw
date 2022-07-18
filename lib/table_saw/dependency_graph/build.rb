# frozen_string_literal: true

module TableSaw
  module DependencyGraph
    class Build
      attr_reader :manifest, :records

      def initialize(manifest)
        @manifest = manifest
        @records = {}
      end

      def call
        manifest.tables.values.sort_by { |t| t.partial? ? 1 : 0 }.each do |table|
          add TableSaw::DependencyGraph::AddDirective.new(table.name, ids: select_ids(table), partial: table.partial?,
                                                                      has_many: table.has_many)
        end

        records
      end

      private

      def add(directive)
        return [] unless directive.queryable?

        directives(directive).select(&:queryable?).each(&method(:add))
      end

      def directives(dir)
        record = records[dir.table_name]

        if record
          dir.partial? ? record.fetch_associations(dir) : []
        else
          TableSaw::DependencyGraph::DumpTable.new(manifest: manifest, name: dir.table_name, partial: dir.partial?)
            .tap { |table| records[dir.table_name] = table }.fetch_associations(dir)
        end
      end

      def select_ids(table)
        return [] unless table.partial?

        TableSaw::Connection.exec(table.query).map { |row| row[TableSaw.primary_key(table.name)] }
      end
    end
  end
end
