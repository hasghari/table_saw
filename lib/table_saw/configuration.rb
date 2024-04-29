# frozen_string_literal: true

module TableSaw
  class Configuration
    attr_writer :variables
    attr_accessor :dbname, :host, :port, :user, :password, :manifest, :output, :format

    def connection
      { dbname:, host:, port:, user:, password: }
    end

    def url=(value)
      URI.parse(value).tap do |uri|
        self.dbname = uri.path[1..]
        self.host = uri.host
        self.port = uri.port
        self.user = uri.user
        self.password = uri.password
      end
    end

    def variables
      @variables || {}
    end
  end
end
