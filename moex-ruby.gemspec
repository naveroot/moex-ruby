# frozen_string_literal: true

require_relative 'lib/moex_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = 'moex-ruby'
  spec.version       = MoexRuby::VERSION
  spec.authors       = ['Pushkin Ivan']
  spec.email         = ['naveroot@gmail.com']

  spec.summary       = 'Ruby client for Moscow Exchange (MOEX) API'
  spec.description   = 'A Ruby gem for interacting with Moscow Exchange API to fetch market data, ' \
                       'securities information, and trading statistics.'
  spec.homepage      = 'https://github.com/naveroot/moex-ruby'
  spec.license       = 'MIT'

  spec.metadata['source_code_uri'] = 'https://github.com/naveroot/moex-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/naveroot/moex-ruby/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/naveroot/moex-ruby/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0'

  # Uncomment to register a new dependency of your gem
  # spec.add_runtime_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
