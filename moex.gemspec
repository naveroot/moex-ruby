# frozen_string_literal: true

require_relative 'lib/moex/version'

Gem::Specification.new do |spec|
  spec.name          = 'moex'
  spec.version       = Moex::VERSION
  spec.authors       = ['Pushkin Ivan']
  spec.email         = ['naveroot@naveroot.ru']
  spec.summary       = 'Ruby client for MOEX ISS (Information & Statistical Server) API'
  spec.description   = <<~DESC
    A comprehensive Ruby client for interacting with the Moscow Exchange ISS API.
    Provides easy access to market data, securities information, trading statistics,
    and other financial data from the Moscow Exchange through a simple and intuitive interface.
  DESC
  spec.homepage      = 'https://github.com/naveroot/moex'
  spec.license       = 'MIT'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/naveroot/moex'
  spec.metadata['changelog_uri'] = 'https://github.com/naveroot/moex/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files = Dir["CHANGELOG.md", "LICENSE", "README.md", "moex.gemspec", "lib/**/*"]
end
