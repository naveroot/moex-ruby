# frozen_string_literal: true

module MoexRuby
  class Error < StandardError; end

  class NetworkError < Error; end
  class ConnectionError < NetworkError; end
  class TimeoutError < NetworkError; end

  class HttpError < Error
    attr_reader :status, :response

    def initialize(message, status: nil, response: nil)
      super(message)
      @status = status
      @response = response
    end
  end

  class ClientError < HttpError; end
  class ServerError < HttpError; end
  class ParseError < Error; end
end
