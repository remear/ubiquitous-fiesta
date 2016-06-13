# frozen_string_literal: true
require 'httmultiparty'
require 'json'
require 'json-schema'

require 'confidence/version'
require 'confidence/extracer'
require 'confidence/tiny_client'
require 'confidence/step_definitions/async_steps'
require 'confidence/step_definitions/debugging_steps'
require 'confidence/step_definitions/http_steps'
require 'confidence/step_definitions/jsonapi_steps'
require 'confidence/step_definitions/validation_steps'
require 'confidence/step_definitions/jsonapi_validation_steps'

require 'confidence/features/support/initial_setup'

module Confidence
  class << self
    attr_accessor :configuration, :client, :logger
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

  class Configuration
    attr_accessor :root_url
    attr_accessor :default_headers
    attr_accessor :max_request_attempts
    attr_accessor :request_attempt_delay

    def initialize
      @root_url = 'http://localhost:3000'
      @default_headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
      @max_request_attempts = 5
      @request_attempt_delay = 2
    end
  end
end
