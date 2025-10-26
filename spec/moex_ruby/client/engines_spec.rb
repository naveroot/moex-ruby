# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby::Client::Engines do
  let(:client) { MoexRuby::Client.new }

  describe '#engines' do
    let(:response_body) do
      {
        'engines' => {
          'columns' => %w[name title],
          'data' => [
            ['stock', 'Фондовый рынок'],
            ['currency', 'Валютный рынок']
          ]
        }
      }
    end

    it 'fetches list of trading engines' do
      stub_request(:get, 'https://iss.moex.com/iss/engines.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.engines
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:name]).to eq('stock')
    end
  end

  describe '#engine' do
    it 'fetches specific engine information' do
      response_body = { 'engine' => { 'columns' => %w[name title], 'data' => [['stock', 'Фондовый рынок']] } }
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.engine('stock')
      expect(result).to be_an(Array)
    end
  end

  describe '#markets' do
    let(:response_body) do
      {
        'markets' => {
          'columns' => %w[name title],
          'data' => [
            ['shares', 'Рынок акций'],
            ['bonds', 'Рынок облигаций']
          ]
        }
      }
    end

    it 'fetches markets for an engine' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.markets('stock')
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:name]).to eq('shares')
    end
  end

  describe '#market' do
    it 'fetches specific market information' do
      response_body = { 'market' => { 'columns' => %w[name title], 'data' => [['shares', 'Рынок акций']] } }
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.market('stock', 'shares')
      expect(result).to be_an(Array)
    end
  end

  describe '#boards' do
    let(:response_body) do
      {
        'boards' => {
          'columns' => %w[boardid title],
          'data' => [
            ['TQBR', 'Т+: Акции и ДР'],
            ['TQTF', 'Т+ ETF']
          ]
        }
      }
    end

    it 'fetches boards for a market' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/boards.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.boards('stock', 'shares')
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:boardid]).to eq('TQBR')
    end
  end

  describe '#board' do
    it 'fetches specific board information' do
      response_body = { 'board' => { 'columns' => %w[boardid title], 'data' => [['TQBR', 'Т+: Акции и ДР']] } }
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.board('stock', 'shares', 'TQBR')
      expect(result).to be_an(Array)
    end
  end

  describe '#board_securities' do
    let(:response_body) do
      {
        'securities' => {
          'columns' => %w[SECID SHORTNAME],
          'data' => [
            %w[SBER Сбербанк],
            %w[GAZP Газпром]
          ]
        }
      }
    end

    it 'fetches securities for a board' do
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR/securities.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.board_securities('stock', 'shares', 'TQBR')
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
    end
  end

  describe '#board_security' do
    it 'fetches specific security on a board' do
      response_body = { 'securities' => { 'columns' => %w[SECID LAST], 'data' => [['SBER', 285.5]] } }
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR/securities/SBER.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.board_security('stock', 'shares', 'TQBR', 'SBER')
      expect(result).to be_an(Array)
    end
  end

  describe '#stock_shares' do
    it 'is an alias for main stock shares board' do
      response_body = { 'securities' => { 'columns' => %w[SECID], 'data' => [['SBER']] } }
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR/securities.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.stock_shares
      expect(result).to be_an(Array)
    end
  end

  describe '#stock_bonds' do
    it 'is an alias for main stock bonds board' do
      response_body = { 'securities' => { 'columns' => %w[SECID], 'data' => [['RU000A0JXQ12']] } }
      stub_request(:get, 'https://iss.moex.com/iss/engines/stock/markets/bonds/boards/TQCB/securities.json')
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      result = client.stock_bonds
      expect(result).to be_an(Array)
    end
  end
end

