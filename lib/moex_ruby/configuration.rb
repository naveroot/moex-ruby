# frozen_string_literal: true

module MoexRuby
  class Configuration
    DEFAULT_BASE_URL = 'https://iss.moex.com'
    DEFAULT_TIMEOUT = 30
    OPEN_TIMEOUT_RATIO = 0.33

    attr_accessor :base_url, :timeout, :open_timeout, :auto_paginate
    attr_reader :middleware_stack

    def initialize
      @base_url = DEFAULT_BASE_URL
      @timeout = DEFAULT_TIMEOUT
      @open_timeout = nil
      @auto_paginate = false
      @middleware_stack = []
      @custom_block = nil
    end

    def request(middleware, *args, **options)
      @middleware_stack << { type: :request, name: middleware, args: args, options: options }
    end

    def response(middleware, *args, **options)
      @middleware_stack << { type: :response, name: middleware, args: args, options: options }
    end

    def adapter(adapter_name = nil)
      @adapter = adapter_name
    end

    def use(middleware, *args, **options, &block)
      combined_args = args
      combined_args << options unless options.empty?
      @middleware_stack << { type: :use, middleware: middleware, args: combined_args, block: block }
    end

    # Для продвинутой кастомизации через блок
    def customize(&block)
      @custom_block = block
    end

    def calculated_open_timeout
      @open_timeout || (@timeout * OPEN_TIMEOUT_RATIO).ceil
    end

    def adapter_name
      @adapter || :net_http
    end

    def apply_to_faraday(faraday)
      # Применяем middleware из стека
      @middleware_stack.each do |config|
        case config[:type]
        when :request
          faraday.request config[:name], *config[:args], **config[:options]
        when :response
          faraday.response config[:name], *config[:args], **config[:options]
        when :use
          faraday.use config[:middleware], *config[:args], &config[:block]
        end
      end

      # Применяем кастомный блок если есть
      @custom_block&.call(faraday)
    end

    def has_custom_middleware?
      @middleware_stack.any? || !@custom_block.nil?
    end
  end
end

