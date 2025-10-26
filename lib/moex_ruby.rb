# frozen_string_literal: true

require_relative 'moex_ruby/version'
require_relative 'moex_ruby/errors'
require_relative 'moex_ruby/data_transformer'
require_relative 'moex_ruby/response'
require_relative 'moex_ruby/error_handler'
require_relative 'moex_ruby/configuration'
require_relative 'moex_ruby/faraday_connection'
require_relative 'moex_ruby/connection_builder'
require_relative 'moex_ruby/pagination_helper'
require_relative 'moex_ruby/client'

module MoexRuby
  class << self
    attr_accessor :logger
  end

  def self.version
    VERSION
  end
end
