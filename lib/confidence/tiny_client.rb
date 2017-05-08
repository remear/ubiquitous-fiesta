# frozen_string_literal: true
module Confidence
  class TinyClient
    attr_accessor :headers, :current_scenario
    attr_reader :extracer, :responses, :storage

    def initialize(extracer)
      @extracer = extracer
      @root_url = Confidence.configuration.root_url
      @headers = Confidence.configuration.default_headers
      @responses = []
      @storage = {}
    end

    def clear_storage
      @storage = {}
    end

    def build_options(opts)
      multipart = opts.delete(:multipart)
      body = opts.delete(:body)
      body = JSON.parse(body) unless [Hash, NilClass].include? body.class # TODO: is this necessary?
      body = hydrater(JSON.dump(body)) if body
      options = {
        headers: headers
      }.tap do |o|
        o[:body] = body if body
        if multipart
          file = opts.delete(:file)
          field = opts.delete(:field)
          o[:body] = {} unless o[:body]
          o[:body][field] = file
        end
      end
    end

    def build_url(endpoint)
      endpoint = hydrater(endpoint)
      url = endpoint =~ /https?:\/\// ? endpoint : "#{@root_url}#{endpoint}"
    end

    def refine_endpoint(ep)
      ep =~ /^\/\S*\/:\S*_id$/ ? ep.sub(/:(\S*_)id/, ':id') : ep
    end

    def request(verb, endpoint, opts = {})
      raise 'HTTP Verb must be a symbol' unless verb.is_a? Symbol
      multipart = opts[:multipart]
      url = build_url(endpoint)
      options = build_options(opts)
      Confidence.logger.debug(options)
      response = if multipart
                   HTTMultiParty.post(url, options)
                 else
                   HTTParty.send(verb, url, options)
                 end
      Confidence.logger.debug(response)
      responses << response
      extracer.log_request(
        verb.to_s.upcase,
        refine_endpoint(endpoint),
        options.fetch(:body, nil),
        last_body,
        response.code,
        response.message
      ) if last_code < 400
      response
    end

    def post(endpoint, body = nil, opts = {})
      request(:post, endpoint, opts.merge!(body: body))
    end

    def post_multipart(endpoint, file, field, _body, opts = {})
      file_name = File.join('fixtures', 'files', file)
      request(:post, endpoint, opts.merge!(multipart: true, file: File.new(file_name), field: field))
    end

    def put(endpoint, body, opts = {})
      request(:put, endpoint, opts.merge!(body: body))
    end

    def patch(endpoint, body, opts = {})
      request(:patch, endpoint, opts.merge!(body: body))
    end

    def get(endpoint)
      request(:get, endpoint)
    end

    def delete(endpoint)
      request(:delete, endpoint)
    end

    def add_response(response)
      responses << response
    end

    def last_code
      responses.last.code
    end

    def last_body
      JSON.parse(responses.last.body) if responses.last.body
    end

    def get_link(keys)
      last_body.dig(*keys.split('.'))
    end

    def hydrater(what)
      return unless what
      what.gsub(/:\w+/) do |match|
        key = match.tr(':', '')
        hydrated_value = storage[key] ? storage[key] : storage[key.to_sym]
        hydrated_value ? hydrated_value : match
      end
    end

    def validate(against)
      file_name = File.join('fixtures', "#{against}.json")
      if File.exist?(file_name) && (!against.is_a? Hash)
        JSON::Validator.validate!(file_name, last_body)
      else
        JSON::Validator.validate!(against, last_body)
      end
    end

    def [](name)
      if last_body.key? name
        last_body[name]
      else
        last_body.select { |x| x != 'links' && x != 'meta' }.values.first[name]
      end
    end
  end
end
