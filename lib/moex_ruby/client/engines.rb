# frozen_string_literal: true

module MoexRuby
  class Client
    module Engines
      def engines(params = {})
        get('/iss/engines', params)
      end

      def engine(engine, params = {})
        get("/iss/engines/#{engine}", params)
      end

      def markets(engine, params = {})
        get("/iss/engines/#{engine}/markets", params)
      end

      def market(engine, market, params = {})
        get("/iss/engines/#{engine}/markets/#{market}", params)
      end

      def boards(engine, market, params = {})
        get("/iss/engines/#{engine}/markets/#{market}/boards", params)
      end

      def board(engine, market, board, params = {})
        get("/iss/engines/#{engine}/markets/#{market}/boards/#{board}", params)
      end

      def board_securities(engine, market, board, params = {})
        get("/iss/engines/#{engine}/markets/#{market}/boards/#{board}/securities", params)
      end

      def board_security(engine, market, board, secid, params = {})
        get("/iss/engines/#{engine}/markets/#{market}/boards/#{board}/securities/#{secid}", params)
      end

      def stock_shares(params = {})
        board_securities('stock', 'shares', 'TQBR', params)
      end

      def stock_bonds(params = {})
        board_securities('stock', 'bonds', 'TQCB', params)
      end
    end
  end
end
