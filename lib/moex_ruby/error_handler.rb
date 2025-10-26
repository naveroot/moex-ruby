# frozen_string_literal: true

require 'faraday'
require_relative 'errors'

module MoexRuby
  class ErrorHandler
    ERROR_MAPPING = {
      Faraday::TimeoutError => TimeoutError,
      Faraday::ConnectionFailed => ConnectionError,
      Faraday::ClientError => ClientError,
      Faraday::ServerError => ServerError
    }.freeze

    def self.handle(faraday_error)
      error = build_error(faraday_error)
      raise error
    end

    def self.handled_errors
      ERROR_MAPPING.keys
    end

    private_class_method def self.build_error(faraday_error)
      error_class = find_error_class(faraday_error)

      if http_error?(faraday_error)
        build_http_error(error_class, faraday_error)
      else
        error_class.new(faraday_error.message)
      end
    end

    private_class_method def self.find_error_class(faraday_error)
      ERROR_MAPPING.each do |faraday_class, our_class|
        return our_class if faraday_error.is_a?(faraday_class)
      end
      Error
    end

    private_class_method def self.http_error?(faraday_error)
      faraday_error.respond_to?(:response) && faraday_error.response
    end

    private_class_method def self.build_http_error(error_class, faraday_error)
      error_class.new(
        faraday_error.message,
        status: faraday_error.response[:status],
        response: faraday_error.response
      )
    end
  end
end
