# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::Client::History do
  let(:client) { MoexRuby::Client.new }

  describe '#security_history' do
    let(:response_body) do
      {
        'history' => {
          'columns' => %w[TRADEDATE CLOSE],
          'data' => [
            ['2024-01-15', 285.5],
            ['2024-01-16', 287.2]
          ]
        }
      }
    end

    it 'fetches security trading history' do
      stub_request(:get, 'https://iss.moex.com/iss/history/engines/stock/markets/shares/securities/SBER.json?from=2024-01-01')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.security_history('SBER', from: '2024-01-01')
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:tradedate]).to eq('2024-01-15')
    end

    it 'accepts date range parameters' do
      stub_request(:get, 'https://iss.moex.com/iss/history/engines/stock/markets/shares/securities/SBER.json?from=2024-01-01&till=2024-01-31')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      client.security_history('SBER', from: '2024-01-01', till: '2024-01-31')
      expect(WebMock).to have_requested(:get, 
        'https://iss.moex.com/iss/history/engines/stock/markets/shares/securities/SBER.json?from=2024-01-01&till=2024-01-31')
    end
  end

  describe '#candles' do
    let(:response_body) do
      {
        'candles' => {
          'columns' => %w[open close high low],
          'data' => [
            [285.0, 287.5, 288.0, 284.5],
            [287.5, 290.0, 291.0, 287.0]
          ]
        }
      }
    end

    it 'fetches OHLC candle data' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/securities/SBER/candles.json?from=2024-01-01&interval=24')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.candles('SBER', from: '2024-01-01', interval: 24)
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:open]).to eq(285.0)
    end

    it 'supports different intervals' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/securities/GAZP/candles.json?interval=60')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      client.candles('GAZP', interval: 60)
      expect(WebMock).to have_requested(:get,
        'https://iss.moex.com/iss/engines/stock/markets/shares/securities/GAZP/candles.json?interval=60')
    end
  end

  describe '#bond_history' do
    it 'fetches bond trading history' do
      response_body = { 'history' => { 'columns' => %w[TRADEDATE CLOSE], 'data' => [['2024-01-15', 1020.5]] } }
      stub_request(:get, 'https://iss.moex.com/iss/history/engines/stock/markets/bonds/securities/RU000A0JXQ12.json?from=2024-01-01')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.bond_history('RU000A0JXQ12', from: '2024-01-01')
      expect(result).to be_an(Array)
    end
  end

  describe '#currency_history' do
    it 'fetches currency trading history' do
      response_body = { 'history' => { 'columns' => %w[TRADEDATE CLOSE], 'data' => [['2024-01-15', 75.5]] } }
      stub_request(:get, 'https://iss.moex.com/iss/history/engines/currency/markets/selt/securities/USD000UTSTOM.json?from=2024-01-01')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.currency_history('USD000UTSTOM', from: '2024-01-01')
      expect(result).to be_an(Array)
    end
  end

  describe '#trading_days' do
    it 'fetches list of trading days' do
      response_body = { 'dates' => { 'columns' => %w[DATE], 'data' => [['2024-01-15'], ['2024-01-16']] } }
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR/dates.json?from=2024-01-01&till=2024-12-31')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.trading_days(from: '2024-01-01', till: '2024-12-31')
      expect(result).to be_an(Array)
    end
  end

  describe '#paginate_history' do
    it 'paginates through history data' do
      page1 = { 'history' => { 'columns' => %w[TRADEDATE], 'data' => [['2024-01-15'], ['2024-01-16']] } }
      page2 = { 'history' => { 'columns' => %w[TRADEDATE], 'data' => [] } }

      stub_request(:get, 'https://iss.moex.com/iss/history/engines/stock/markets/shares/securities/SBER.json?from=2024-01-01&start=0')
        .to_return(status: 200, body: page1.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/history/engines/stock/markets/shares/securities/SBER.json?from=2024-01-01&start=2')
        .to_return(status: 200, body: page2.to_json, headers: { 'Content-Type' => 'application/json' })

      pages = []
      client.paginate_history('SBER', from: '2024-01-01') { |page| pages << page }

      expect(pages.size).to eq(1)
      expect(pages.first.size).to eq(2)
    end
  end

  describe '#paginate_candles' do
    it 'paginates through candles data' do
      page1 = { 'candles' => { 'columns' => %w[open close], 'data' => [[285.0, 287.5]] } }
      page2 = { 'candles' => { 'columns' => %w[open close], 'data' => [] } }

      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/securities/SBER/candles.json?interval=24&start=0')
        .to_return(status: 200, body: page1.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/securities/SBER/candles.json?interval=24&start=1')
        .to_return(status: 200, body: page2.to_json, headers: { 'Content-Type' => 'application/json' })

      pages = []
      client.paginate_candles('SBER', interval: 24) { |page| pages << page }

      expect(pages.size).to eq(1)
    end
  end
end

