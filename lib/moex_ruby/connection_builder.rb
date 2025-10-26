# frozen_string_literal: true

require 'faraday'
require_relative 'faraday_connection'
require_relative 'configuration'

module MoexRuby
  class ConnectionBuilder
    def initialize(configuration)
      @config = configuration
    end

    def build
      faraday = build_faraday_connection
      FaradayConnection.new(faraday)
    end

    private

    def build_faraday_connection
      Faraday.new(url: @config.base_url) do |f|
        configure_defaults(f)
        apply_custom_configuration(f)
      end
    end

    def configure_defaults(faraday)
      unless @config.has_custom_middleware?
        faraday.request :url_encoded
        faraday.response :json, content_type: /\bjson$/
        faraday.response :raise_error
      end

      faraday.options.timeout = @config.timeout
      faraday.options.open_timeout = @config.calculated_open_timeout

      faraday.adapter @config.adapter_name unless @config.has_custom_middleware?
    end

    def apply_custom_configuration(faraday)
      @config.apply_to_faraday(faraday) if @config.has_custom_middleware?
    end
  end
end
