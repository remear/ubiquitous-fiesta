# frozen_string_literal: true
require 'logger'
require 'test/unit/assertions'

World(Test::Unit::Assertions)

extracer = Specr::Extracer.new

AfterConfiguration do
  Specr.logger = Logger.new(STDOUT)
  Specr.logger.level = Logger::FATAL
  Specr.client = Specr::TinyClient.new(extracer)
end

Before do |scenario|
  Specr.client.clear_storage
  Specr.client.current_scenario = scenario
end

Before('@cleanroom') do
  Specr.client.clear_storage
end

at_exit do
  Specr.client.extracer.save
end
