# frozen_string_literal: true

module MoexRuby
  class Client
    module Securities
      def security(secid, params = {})
        get("/iss/securities/#{secid}", params)
      end

      def securities(params = {})
        get('/iss/securities', params)
      end

      def search_securities(query, params = {})
        securities(params.merge(q: query))
      end

      def indices(params = {})
        get('/iss/statistics/engines/stock/markets/index/analytics', params)
      end

      def index(secid, params = {})
        security(secid, params)
      end

      def securities_aggregates(params = {})
        get('/iss/securities/aggregates', params)
      end
    end
  end
end
