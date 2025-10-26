# frozen_string_literal: true

module MoexRuby
  class Client
    module History
      def security_history(secid, params = {})
        get("/iss/history/engines/stock/markets/shares/securities/#{secid}", params)
      end

      def candles(secid, params = {})
        get("/iss/engines/stock/markets/shares/securities/#{secid}/candles", params)
      end

      def bond_history(secid, params = {})
        get("/iss/history/engines/stock/markets/bonds/securities/#{secid}", params)
      end

      def currency_history(secid, params = {})
        get("/iss/history/engines/currency/markets/selt/securities/#{secid}", params)
      end

      def trading_days(params = {})
        get('/iss/engines/stock/markets/shares/boards/TQBR/dates', params)
      end

      def paginate_history(secid, params = {}, &block)
        path = "/iss/history/engines/stock/markets/shares/securities/#{secid}"
        paginate(path, params, &block)
      end

      def paginate_candles(secid, params = {}, &block)
        path = "/iss/engines/stock/markets/shares/securities/#{secid}/candles"
        paginate(path, params, &block)
      end
    end
  end
end
