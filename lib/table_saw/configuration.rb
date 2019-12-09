# frozen_string_literal: true

module TableSaw
  class Configuration
    attr_accessor :dbname, :host, :port, :user, :password, :manifest, :output, :format

    def connection
      { dbname: dbname, host: host, port: port, user: user, password: password }
    end

    def url=(value)
      URI.parse(value).tap do |uri|
        self.dbname = uri.path[1..-1]
        self.host = uri.host
        self.port = uri.port
        self.user = uri.user
        self.password = uri.password
      end
    end
  end
end
