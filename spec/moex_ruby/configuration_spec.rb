# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::Configuration do
  subject(:config) { described_class.new }

  describe '#initialize' do
    it 'sets default values' do
      expect(config.base_url).to eq('https://iss.moex.com')
      expect(config.timeout).to eq(30)
      expect(config.open_timeout).to be_nil
      expect(config.auto_paginate).to eq(false)
      expect(config.middleware_stack).to eq([])
    end
  end

  describe '#auto_paginate' do
    it 'can be set to true' do
      config.auto_paginate = true
      expect(config.auto_paginate).to eq(true)
    end

    it 'can be set to false' do
      config.auto_paginate = false
      expect(config.auto_paginate).to eq(false)
    end

    it 'defaults to false' do
      expect(config.auto_paginate).to eq(false)
    end
  end

  describe '#request' do
    it 'adds request middleware to stack' do
      config.request :url_encoded
      
      expect(config.middleware_stack).to contain_exactly(
        { type: :request, name: :url_encoded, args: [], options: {} }
      )
    end

    it 'supports args and options' do
      config.request :retry, max: 3, interval: 0.5
      
      expect(config.middleware_stack.first).to include(
        type: :request,
        name: :retry,
        options: { max: 3, interval: 0.5 }
      )
    end
  end

  describe '#response' do
    it 'adds response middleware to stack' do
      config.response :json, content_type: /\bjson$/
      
      expect(config.middleware_stack).to contain_exactly(
        { type: :response, name: :json, args: [], options: { content_type: /\bjson$/ } }
      )
    end

    it 'supports multiple response middleware' do
      config.response :raise_error
      config.response :logger, nil, { bodies: true }
      
      expect(config.middleware_stack.size).to eq(2)
      expect(config.middleware_stack.first[:name]).to eq(:raise_error)
      expect(config.middleware_stack.last[:name]).to eq(:logger)
    end
  end

  describe '#adapter' do
    it 'sets custom adapter' do
      config.adapter :typhoeus
      expect(config.adapter_name).to eq(:typhoeus)
    end

    it 'defaults to net_http' do
      expect(config.adapter_name).to eq(:net_http)
    end
  end

  describe '#use' do
    it 'adds custom middleware to stack' do
      middleware_class = Class.new
      config.use middleware_class, option: 'value'
      
      expect(config.middleware_stack).to contain_exactly(
        { type: :use, middleware: middleware_class, args: [{ option: 'value' }], block: nil }
      )
    end

    it 'supports block' do
      block = proc { |env| env }
      config.use Class.new, &block
      
      expect(config.middleware_stack.first[:block]).to eq(block)
    end
  end

  describe '#customize' do
    it 'stores custom block' do
      block = proc { |f| f.adapter :test }
      config.customize(&block)
      
      expect(config.instance_variable_get(:@custom_block)).to eq(block)
    end
  end

  describe '#calculated_open_timeout' do
    it 'calculates from timeout if not set' do
      config.timeout = 30
      expect(config.calculated_open_timeout).to eq(10) # 30 * 0.33 = 9.9 -> 10
    end

    it 'uses explicit value if set' do
      config.timeout = 30
      config.open_timeout = 5
      expect(config.calculated_open_timeout).to eq(5)
    end
  end

  describe '#has_custom_middleware?' do
    it 'returns false by default' do
      expect(config.has_custom_middleware?).to be false
    end

    it 'returns true when middleware added' do
      config.request :url_encoded
      expect(config.has_custom_middleware?).to be true
    end

    it 'returns true when custom block set' do
      config.customize { |f| f.adapter :test }
      expect(config.has_custom_middleware?).to be true
    end
  end

  describe '#apply_to_faraday' do
    let(:faraday) { instance_double(Faraday::Connection) }

    it 'applies request middleware' do
      config.request :url_encoded
      config.request :retry, max: 3

      expect(faraday).to receive(:request).with(:url_encoded)
      expect(faraday).to receive(:request).with(:retry, max: 3)

      config.apply_to_faraday(faraday)
    end

    it 'applies response middleware' do
      config.response :json, content_type: /\bjson$/
      config.response :raise_error

      expect(faraday).to receive(:response).with(:json, content_type: /\bjson$/)
      expect(faraday).to receive(:response).with(:raise_error)

      config.apply_to_faraday(faraday)
    end

    it 'applies custom middleware' do
      middleware_class = Class.new
      config.use middleware_class, option: 'value'

      expect(faraday).to receive(:use).with(middleware_class, { option: 'value' })

      config.apply_to_faraday(faraday)
    end

    it 'calls custom block' do
      called = false
      config.customize { |f| called = true }

      config.apply_to_faraday(faraday)

      expect(called).to be true
    end
  end
end

