# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MoexRuby do
  it 'has a version number' do
    expect(MoexRuby::VERSION).not_to be_nil
  end

  it 'defines the Error class' do
    expect(MoexRuby::Error).to be < StandardError
  end
end
