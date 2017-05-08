# frozen_string_literal: true
require 'logger'
require 'test/unit/assertions'

World(Test::Unit::Assertions)

extracer = Confidence::Extracer.new

AfterConfiguration do
  Confidence.logger = Logger.new(STDOUT)
  Confidence.logger.level = Logger::FATAL
  Confidence.client = Confidence::TinyClient.new(extracer)
end

Before do |scenario|
  Confidence.client.clear_storage
  Confidence.client.current_scenario = scenario
end

Before('@cleanroom') do
  Confidence.client.clear_storage
end

at_exit do
  Confidence.client.extracer.save
end
