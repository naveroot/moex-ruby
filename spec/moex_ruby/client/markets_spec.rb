# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::Client::Markets do
  let(:client) { MoexRuby::Client.new }

  describe '#market_data' do
    let(:response_body) do
      {
        'marketdata' => {
          'columns' => %w[SECID LAST BID ASK],
          'data' => [['SBER', 285.5, 285.4, 285.6]]
        }
      }
    end

    it 'fetches current market data for a security' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/securities/SBER.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.market_data('SBER')
      expect(result).to be_an(Array)
      expect(result.first[:secid]).to eq('SBER')
    end

    it 'supports custom engine and market' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/currency/markets/selt/securities/USD000UTSTOM.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      client.market_data('USD000UTSTOM', engine: 'currency', market: 'selt')
      expect(WebMock).to have_requested(:get,
        'https://iss.moex.com/iss/engines/currency/markets/selt/securities/USD000UTSTOM.json')
    end
  end

  describe '#order_book' do
    let(:response_body) do
      {
        'orderbook' => {
          'columns' => %w[SECID BID ASK BIDDEPTH ASKDEPTH],
          'data' => [['SBER', 285.4, 285.6, 1000, 1500]]
        }
      }
    end

    it 'fetches order book for a security' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/orderbook/SBER.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.order_book('SBER')
      expect(result).to be_an(Array)
    end
  end

  describe '#trades' do
    let(:response_body) do
      {
        'trades' => {
          'columns' => %w[SECID PRICE QUANTITY],
          'data' => [
            ['SBER', 285.5, 100],
            ['SBER', 285.6, 200]
          ]
        }
      }
    end

    it 'fetches recent trades for a security' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/trades/SBER.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.trades('SBER')
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
    end
  end

  describe '#trading_session' do
    let(:response_body) do
      {
        'securities' => {
          'columns' => %w[SECID LAST VOLUME],
          'data' => [
            ['SBER', 285.5, 1000000],
            ['GAZP', 175.2, 500000]
          ]
        }
      }
    end

    it 'fetches trading session results' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/securities.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.trading_session
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
    end

    it 'accepts date parameter' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/securities.json?date=2024-01-15')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      client.trading_session(date: '2024-01-15')
      expect(WebMock).to have_requested(:get,
        'https://iss.moex.com/iss/engines/stock/markets/shares/securities.json?date=2024-01-15')
    end
  end

  describe '#top_securities' do
    let(:response_body) do
      {
        'securities' => {
          'columns' => %w[SECID VOLUME],
          'data' => [
            ['SBER', 5000000],
            ['GAZP', 3000000]
          ]
        }
      }
    end

    it 'fetches top securities by volume' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/securities.json?limit=20')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.top_securities(limit: 20)
      expect(result).to be_an(Array)
    end
  end

  describe '#turnovers' do
    it 'fetches market turnovers' do
      response_body = { 'turnovers' => { 'columns' => %w[NAME VALUE], 'data' => [['Shares', 100000000]] } }
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/turnovers.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.turnovers
      expect(result).to be_an(Array)
    end
  end

  describe '#issuers' do
    let(:response_body) do
      {
        'issuers' => {
          'columns' => %w[id title],
          'data' => [
            [1, 'ПАО Сбербанк'],
            [2, 'ПАО Газпром']
          ]
        }
      }
    end

    it 'fetches list of issuers' do
      stub_request(:get, 'https://iss.moex.com/iss/securities/issuers.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.issuers
      expect(result).to be_an(Array)
    end

    it 'supports search query' do
      stub_request(:get, 'https://iss.moex.com/iss/securities/issuers.json?q=%D0%93%D0%B0%D0%B7%D0%BF%D1%80%D0%BE%D0%BC')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      client.issuers(q: 'Газпром')
      expect(WebMock).to have_requested(:get, 
        'https://iss.moex.com/iss/securities/issuers.json?q=%D0%93%D0%B0%D0%B7%D0%BF%D1%80%D0%BE%D0%BC')
    end
  end

  describe '#issuer' do
    it 'fetches specific issuer information' do
      response_body = { 'issuer' => { 'columns' => %w[id title], 'data' => [[1234, 'ПАО Сбербанк']] } }
      stub_request(:get, 'https://iss.moex.com/iss/securities/issuers/1234.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.issuer(1234)
      expect(result).to be_an(Array)
    end
  end

  describe '#open_interest' do
    let(:response_body) do
      {
        'securities' => {
          'columns' => %w[SECID OPENINTEREST],
          'data' => [['USDRUBF', 100000]]
        }
      }
    end

    it 'fetches open interest for a security' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/currency/markets/futures/securities/USDRUBF.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.open_interest('USDRUBF')
      expect(result).to be_an(Array)
      expect(result.first[:secid]).to eq('USDRUBF')
    end

    it 'supports custom engine and market' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/futures/securities/SBERF.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.open_interest('SBERF', engine: 'stock', market: 'futures')
      expect(result).to be_an(Array)
    end
  end

  describe '#open_interest_on_date' do
    let(:response_body) do
      {
        'securities' => {
          'columns' => %w[SECID OPENINTEREST],
          'data' => [['USDRUBF', 95000]]
        }
      }
    end

    it 'fetches open interest for a specific date' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/currency/markets/futures/securities/USDRUBF.json?date=2024-01-15')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.open_interest_on_date('USDRUBF', '2024-01-15')
      expect(result).to be_an(Array)
      expect(WebMock).to have_requested(:get,
        'https://iss.moex.com/iss/engines/currency/markets/futures/securities/USDRUBF.json?date=2024-01-15')
    end
  end
end

