# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::Client do
  let(:client) { described_class.new }

  describe '#initialize' do
    it 'creates client with default configuration' do
      expect(client).to be_a(described_class)
      expect(client.config).to be_a(MoexRuby::Configuration)
      expect(client.config.timeout).to eq(30)
      expect(client.auto_paginate).to eq(false)
    end

    it 'accepts custom timeout' do
      custom_client = described_class.new(timeout: 60)
      expect(custom_client.config.timeout).to eq(60)
    end

    it 'accepts auto_paginate option' do
      custom_client = described_class.new(auto_paginate: true)
      expect(custom_client.auto_paginate).to eq(true)
      expect(custom_client.config.auto_paginate).to eq(true)
    end

    it 'accepts auto_paginate in configuration block' do
      custom_client = described_class.new do |config|
        config.auto_paginate = true
        config.timeout = 45
      end

      expect(custom_client.auto_paginate).to eq(true)
      expect(custom_client.config.timeout).to eq(45)
    end

    it 'accepts configuration block' do
      custom_client = described_class.new do |config|
        config.timeout = 45
        config.base_url = 'https://custom.moex.com'
      end

      expect(custom_client.config.timeout).to eq(45)
      expect(custom_client.config.base_url).to eq('https://custom.moex.com')
    end

    it 'combines timeout parameter with configuration block' do
      custom_client = described_class.new(timeout: 20) do |config|
        config.base_url = 'https://test.moex.com'
      end

      expect(custom_client.config.timeout).to eq(20)
      expect(custom_client.config.base_url).to eq('https://test.moex.com')
    end

    it 'allows adding middleware through configuration' do
      custom_client = described_class.new do |config|
        config.response :raise_error
        config.response :logger
      end

      expect(custom_client.config.middleware_stack.size).to eq(2)
    end

    it 'accepts custom connection' do
      custom_connection = instance_double(MoexRuby::FaradayConnection)
      custom_client = described_class.new(connection: custom_connection)

      expect(custom_client.connection).to eq(custom_connection)
    end
  end

  describe '#get' do
    let(:response_body) do
      {
        'securities' => {
          'columns' => %w[SECID NAME],
          'data' => [%w[SBER Sberbank]]
        }
      }
    end

    it 'makes GET request and parses response' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.get('/iss/securities')
      expect(result).to be_an(Array)
      expect(result.first[:secid]).to eq('SBER')
    end

    it 'automatically adds .json extension' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      client.get('/iss/securities')
      expect(WebMock).to have_requested(:get, 'https://iss.moex.com/iss/securities.json')
    end

    it 'passes query parameters' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?date=2024-01-15')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      client.get('/iss/securities', date: '2024-01-15')
      expect(WebMock).to have_requested(:get, 'https://iss.moex.com/iss/securities.json?date=2024-01-15')
    end

    it 'raises error on timeout' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json').to_timeout

      expect { client.get('/iss/securities') }.to raise_error(MoexRuby::Error)
    end

    it 'raises ConnectionError on connection failure' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json').to_raise(Faraday::ConnectionFailed)

      expect { client.get('/iss/securities') }.to raise_error(MoexRuby::ConnectionError)
    end
  end

  describe '#get with auto_paginate' do
    let(:auto_client) { described_class.new(auto_paginate: true) }
    let(:page1_body) do
      {
        'securities' => {
          'columns' => %w[SECID NAME],
          'data' => [
            %w[SBER Sberbank],
            %w[GAZP Gazprom]
          ]
        }
      }
    end
    let(:page2_body) do
      {
        'securities' => {
          'columns' => %w[SECID NAME],
          'data' => [%w[LKOH Lukoil]]
        }
      }
    end
    let(:page3_body) do
      {
        'securities' => {
          'columns' => %w[SECID NAME],
          'data' => []
        }
      }
    end

    it 'automatically fetches all pages when auto_paginate is enabled' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?start=0')
        .to_return(status: 200, body: page1_body.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?start=2')
        .to_return(status: 200, body: page2_body.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?start=3')
        .to_return(status: 200, body: page3_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = auto_client.get('/iss/securities')
      
      expect(result).to be_an(Array)
      expect(result.size).to eq(3)
      expect(result.map { |r| r[:secid] }).to eq(%w[SBER GAZP LKOH])
    end

    it 'can toggle auto_paginate dynamically' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json')
        .to_return(status: 200, body: page1_body.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?start=0')
        .to_return(status: 200, body: page1_body.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?start=2')
        .to_return(status: 200, body: page3_body.to_json, headers: { 'Content-Type' => 'application/json' })

      # Без автопагинации
      client.auto_paginate = false
      result1 = client.get('/iss/securities')
      expect(result1.size).to eq(2)

      # С автопагинацией
      client.auto_paginate = true
      result2 = client.get('/iss/securities')
      expect(result2.size).to eq(2)
    end

    it 'works with methods from modules' do
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?start=0')
        .to_return(status: 200, body: page1_body.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?start=2')
        .to_return(status: 200, body: page2_body.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/securities.json?start=3')
        .to_return(status: 200, body: page3_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = auto_client.securities
      expect(result.size).to eq(3)
    end
  end

  describe '#paginate' do
    it 'iterates through all pages' do
      page1 = { 'data' => { 'columns' => %w[ID], 'data' => [[1], [2]] } }
      page2 = { 'data' => { 'columns' => %w[ID], 'data' => [[3]] } }
      page3 = { 'data' => { 'columns' => %w[ID], 'data' => [] } }

      stub_request(:get, 'https://iss.moex.com/iss/test.json?start=0')
        .to_return(status: 200, body: page1.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/test.json?start=2')
        .to_return(status: 200, body: page2.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/test.json?start=3')
        .to_return(status: 200, body: page3.to_json, headers: { 'Content-Type' => 'application/json' })

      pages = []
      client.paginate('/iss/test') { |page| pages << page }

      expect(pages.size).to eq(2)
      expect(pages[0].size).to eq(2)
      expect(pages[1].size).to eq(1)
    end

    it 'returns enumerator when no block given' do
      page1 = { 'data' => { 'columns' => %w[ID], 'data' => [[1]] } }
      page2 = { 'data' => { 'columns' => %w[ID], 'data' => [] } }

      stub_request(:get, 'https://iss.moex.com/iss/test.json?start=0')
        .to_return(status: 200, body: page1.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/test.json?start=1')
        .to_return(status: 200, body: page2.to_json, headers: { 'Content-Type' => 'application/json' })

      enum = client.paginate('/iss/test')
      expect(enum).to be_a(Enumerator)
      expect(enum.to_a.size).to eq(1)
    end

    it 'handles multiple data blocks correctly in pagination' do
      page1 = {
        'securities' => { 'columns' => %w[ID], 'data' => [[1], [2]] },
        'marketdata' => { 'columns' => %w[ID], 'data' => [[1], [2]] }
      }
      page2 = {
        'securities' => { 'columns' => %w[ID], 'data' => [[3]] },
        'marketdata' => { 'columns' => %w[ID], 'data' => [[3]] }
      }
      page3 = {
        'securities' => { 'columns' => %w[ID], 'data' => [] },
        'marketdata' => { 'columns' => %w[ID], 'data' => [] }
      }

      stub_request(:get, 'https://iss.moex.com/iss/test.json?start=0')
        .to_return(status: 200, body: page1.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/test.json?start=2')
        .to_return(status: 200, body: page2.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/test.json?start=3')
        .to_return(status: 200, body: page3.to_json, headers: { 'Content-Type' => 'application/json' })

      pages = []
      client.paginate('/iss/test') { |page| pages << page }

      expect(pages.size).to eq(2)
      expect(pages[0]).to be_a(Hash)
      expect(pages[0][:securities].size).to eq(2)
      expect(pages[1][:securities].size).to eq(1)
    end

    context 'memory efficiency with large datasets' do
      let(:auto_client) { described_class.new(auto_paginate: true) }

      it 'does not load all data into memory at once' do
        page_size = 50
        total_pages = 10
        start_value = 0

        requests_made = []

        total_pages.times do |page_num|
          page_data = (1..page_size).map { |i| { id: page_num * page_size + i, value: "data#{i}" } }
          response = { 'data' => { 'columns' => %w[id value], 'data' => page_data.map { |d| [d[:id], d[:value]] } } }

          stub_request(:get, "https://iss.moex.com/iss/test.json?start=#{start_value}")
            .to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })

          start_value += page_size
        end

        result = auto_client.get('/iss/test')

        expect(result).to be_a(MoexRuby::LazyResult)
        expect(requests_made.size).to eq(0)

        item_count = 0
        result.each do |item|
          item_count += 1
          break if item_count >= 2
        end

        expect(item_count).to eq(2)
        expect(result).to respond_to(:size)
      end

      it 'caches data only when to_a is called' do
        page1 = { 'data' => { 'columns' => %w[ID], 'data' => [[1], [2], [3]] } }
        page2 = { 'data' => { 'columns' => %w[ID], 'data' => [[4], [5], [6]] } }
        page3 = { 'data' => { 'columns' => %w[ID], 'data' => [] } }

        stub_request(:get, 'https://iss.moex.com/iss/test.json?start=0')
          .to_return(status: 200, body: page1.to_json, headers: { 'Content-Type' => 'application/json' })
        stub_request(:get, 'https://iss.moex.com/iss/test.json?start=3')
          .to_return(status: 200, body: page2.to_json, headers: { 'Content-Type' => 'application/json' })
        stub_request(:get, 'https://iss.moex.com/iss/test.json?start=6')
          .to_return(status: 200, body: page3.to_json, headers: { 'Content-Type' => 'application/json' })

        result = auto_client.get('/iss/test')

        initial_cache_state = result.instance_variable_get(:@cached_array)
        expect(initial_cache_state).to be_nil

        cached = result.to_a
        expect(cached).to be_an(Array)
        expect(cached.size).to eq(6)

        cached_state = result.instance_variable_get(:@cached_array)
        expect(cached_state).to be_an(Array)
        expect(cached_state.size).to eq(6)
      end

      it 'implements Array-like methods correctly' do
        page1 = { 'data' => { 'columns' => %w[ID], 'data' => [[1], [2], [3]] } }
        page2 = { 'data' => { 'columns' => %w[ID], 'data' => [] } }

        stub_request(:get, 'https://iss.moex.com/iss/test.json?start=0')
          .to_return(status: 200, body: page1.to_json, headers: { 'Content-Type' => 'application/json' })
        stub_request(:get, 'https://iss.moex.com/iss/test.json?start=3')
          .to_return(status: 200, body: page2.to_json, headers: { 'Content-Type' => 'application/json' })

        result = auto_client.get('/iss/test')

        expect(result.empty?).to be(false)
        expect(result.length).to eq(3)
        expect(result[0]).to eq(id: 1)
        expect(result.is_a?(Array)).to be(true)
      end
    end
  end
end
