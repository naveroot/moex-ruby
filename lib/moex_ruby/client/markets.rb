# frozen_string_literal: true

module MoexRuby
  class Client
    module Markets
      def market_data(secid, params = {})
        engine = params.delete(:engine) || 'stock'
        market = params.delete(:market) || 'shares'
        get("/iss/engines/#{engine}/markets/#{market}/securities/#{secid}", params)
      end

      def order_book(secid, params = {})
        engine = params.delete(:engine) || 'stock'
        market = params.delete(:market) || 'shares'
        get("/iss/engines/#{engine}/markets/#{market}/orderbook/#{secid}", params)
      end

      def trades(secid, params = {})
        engine = params.delete(:engine) || 'stock'
        market = params.delete(:market) || 'shares'
        get("/iss/engines/#{engine}/markets/#{market}/trades/#{secid}", params)
      end

      def trading_session(params = {})
        engine = params.delete(:engine) || 'stock'
        market = params.delete(:market) || 'shares'
        get("/iss/engines/#{engine}/markets/#{market}/securities", params)
      end

      def top_securities(params = {})
        params[:limit] ||= 20
        trading_session(params)
      end

      def turnovers(params = {})
        get('/iss/engines/stock/turnovers', params)
      end

      def issuers(params = {})
        get('/iss/securities/issuers', params)
      end

      def issuer(issuer_id, params = {})
        get("/iss/securities/issuers/#{issuer_id}", params)
      end

      def open_interest(secid, params = {})
        engine = params.delete(:engine) || 'currency'
        market = params.delete(:market) || 'futures'
        get("/iss/engines/#{engine}/markets/#{market}/securities/#{secid}", params)
      end

      def open_interest_on_date(secid, date, params = {})
        engine = params.delete(:engine) || 'currency'
        market = params.delete(:market) || 'futures'
        get("/iss/engines/#{engine}/markets/#{market}/securities/#{secid}", params.merge(date: date))
      end
    end
  end
end
