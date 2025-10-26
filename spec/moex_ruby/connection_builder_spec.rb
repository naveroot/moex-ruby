# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::ConnectionBuilder do
  let(:config) { MoexRuby::Configuration.new }

  describe '#build' do
    it 'creates Connection with default settings' do
      builder = described_class.new(config)
      connection = builder.build

      expect(connection).to be_a(MoexRuby::FaradayConnection)
      expect(connection.instance_variable_get(:@faraday_connection).url_prefix.to_s).to eq('https://iss.moex.com/')
    end

    it 'uses custom base_url from configuration' do
      config.base_url = 'https://example.com'
      builder = described_class.new(config)
      connection = builder.build

      expect(connection.instance_variable_get(:@faraday_connection).url_prefix.to_s).to eq('https://example.com/')
    end

    it 'uses custom timeout from configuration' do
      config.timeout = 60
      builder = described_class.new(config)
      connection = builder.build

      faraday_connection = connection.instance_variable_get(:@faraday_connection)
      expect(faraday_connection.options.timeout).to eq(60)
      expect(faraday_connection.options.open_timeout).to eq(20) # 60 * 0.33 = 19.8 -> 20
    end

    it 'applies default middleware when no custom middleware configured' do
      builder = described_class.new(config)
      connection = builder.build

      faraday_connection = connection.instance_variable_get(:@faraday_connection)
      middleware_classes = faraday_connection.builder.handlers.map(&:klass)

      expect(middleware_classes).to include(Faraday::Request::UrlEncoded)
      expect(middleware_classes).to include(Faraday::Response::Json)
      expect(middleware_classes).to include(Faraday::Response::RaiseError)
    end

    it 'applies custom middleware from configuration' do
      config.response :logger
      config.request :url_encoded

      builder = described_class.new(config)
      connection = builder.build

      faraday_connection = connection.instance_variable_get(:@faraday_connection)
      middleware_classes = faraday_connection.builder.handlers.map(&:klass)

      expect(middleware_classes).to include(Faraday::Response::Logger)
      expect(middleware_classes).to include(Faraday::Request::UrlEncoded)
    end

    it 'applies custom block from configuration' do
      middleware_called = false
      config.customize do |faraday|
        middleware_called = true
        expect(faraday).to be_a(Faraday::Connection)
      end

      builder = described_class.new(config)
      builder.build

      expect(middleware_called).to be true
    end

    it 'does not apply default middleware when custom middleware present' do
      config.response :logger

      builder = described_class.new(config)
      connection = builder.build

      faraday_connection = connection.instance_variable_get(:@faraday_connection)
      middleware_classes = faraday_connection.builder.handlers.map(&:klass)

      # Не должно быть дефолтных middleware
      expect(middleware_classes).not_to include(Faraday::Request::UrlEncoded)
      expect(middleware_classes).to include(Faraday::Response::Logger)
    end

    it 'uses custom adapter from configuration' do
      config.adapter :test
      builder = described_class.new(config)
      connection = builder.build

      faraday_connection = connection.instance_variable_get(:@faraday_connection)
      expect(faraday_connection.builder.adapter).to eq(Faraday::Adapter::Test)
    end
  end
end

