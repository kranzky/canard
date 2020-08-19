# frozen_string_literal: true

require 'simplecov'

module SimpleCov::Configuration # rubocop:disable Style/ClassAndModuleChildren
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
  load_profile 'test_frameworks'
end

ENV['COVERAGE'] && SimpleCov.start do
  add_filter '/.rvm/'
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'canard'
require 'canard/bowling'

Q << File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', 'QUACKS.md')))
