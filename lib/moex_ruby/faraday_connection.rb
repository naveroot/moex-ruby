# frozen_string_literal: true

require_relative 'response'
require_relative 'error_handler'

module MoexRuby
  class FaradayConnection
    HANDLED_ERRORS = ErrorHandler.handled_errors.freeze

    def initialize(faraday_connection)
      @faraday_connection = faraday_connection
    end

    def get(path, params = {})
      response = @faraday_connection.get(path, params)
      Response.parse(response.body)
    rescue *HANDLED_ERRORS => e
      ErrorHandler.handle(e)
    end
  end
end
