# frozen_string_literal: true

require 'forwardable'
require_relative 'connection_builder'
require_relative 'configuration'
require_relative 'response'
require_relative 'pagination_helper'
require_relative 'client/securities'
require_relative 'client/history'
require_relative 'client/engines'
require_relative 'client/markets'

module MoexRuby
  class Client
    extend Forwardable
    
    include Client::Securities
    include Client::History
    include Client::Engines
    include Client::Markets

    attr_reader :connection, :config
    
    def_delegators :@config, :auto_paginate, :auto_paginate=

    def initialize(connection: nil, **config_options, &block)
      @config = build_configuration(config_options, &block)
      @connection = connection || build_default_connection
    end

    def get(path, params = {})
      return perform_request(path, params) unless @config.auto_paginate
      
      auto_paginate_get(path, params)
    end

    def paginate(path, params = {})
      return enum_for(:paginate, path, params) unless block_given?

      start = 0
      loop do
        data = perform_request(path, params.merge(start: start))
        size = PaginationHelper.extract_size(data)
        break if size.zero?

        yield data
        start += size
      end
    end

    private

    def perform_request(path, params)
      formatted_path = ensure_json_format(path)
      @connection.get(formatted_path, params)
    end

    def auto_paginate_get(path, params)
      [].tap do |all_data|
        paginate(path, params) do |page_data|
          all_data.concat(PaginationHelper.normalize_data(page_data))
        end
      end
    end

    def ensure_json_format(path)
      path.end_with?('.json') ? path : "#{path}.json"
    end

    def build_configuration(options, &block)
      Configuration.new.tap do |config|
        apply_options(config, options)
        block&.call(config)
      end
    end

    def apply_options(config, options)
      options.each do |key, value|
        next if value.nil?
        
        setter = "#{key}="
        config.public_send(setter, value) if config.respond_to?(setter)
      end
    end

    def build_default_connection
      ConnectionBuilder.new(@config).build
    end
  end
end
