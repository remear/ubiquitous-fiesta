# frozen_string_literal: true
module Confidence
  class Extracer
    def initialize
      @requests = []
      @resources_create = Hash.new([])
      @resources_update = Hash.new([])
    end

    def log_request(method, endpoint, request, response)
      if request.is_a? String
        begin
          request = JSON.parse(request)
        rescue
          # WHAT ARE WE EVEN GETTING
          return
        end
      end
      req = {
        method: method,
        endpoint: endpoint,
        request: (request || {}),
        response: (response || {})
      }
      @requests << req
      unless response
        # likely a 204 with a delete request
        return
      end
      # TODO: make these extract from arrays when those are being used
      if endpoint.start_with?(Confidence.configuration.root_url)
        endpoint = endpoint[Confidence.configuration.root_url.length..-1]
      end
      if method == 'POST'
        # the path is either /[resource_name] or /[some_other_resource]/[guid]/[resource_name]
        # and the resource is getting created
        resource = endpoint.split('/').last
        @resources_create[resource] += [req]
      elsif method == 'PATCH'
        # the path will be /[resource_name]/[guid]
        resource = endpoint.split('/')[1]
        @resources_update[resource] += [req]
      end
      # 'GET' & 'DELETE' requests are ignored, and 'PUT' can be similar to a 'PATCH' in updating
    end

    def save
      file = File.join('specification.json')
      json = {
        endpoints: load_endpoints,
        requests: @requests,
        resources_create: @resources_create,
        resources_update: @resources_update,
        schemas: load_schemas
      }
      File.open(file, 'w') { |f| f.write(JSON.pretty_generate(json)) }
    end

    private

    def resolve_refs(json, path)
      if json.is_a? Hash
        if json['$ref']
          path = File.join(File.dirname(path), json['$ref'])
          json.delete('$ref')
          Hash[resolve_refs(JSON.parse(File.read(path)), path).to_a + json.to_a]
        else
          Hash[json.map do |key, value|
                 [key, resolve_refs(value, path)]
               end]
        end
      elsif json.is_a? Array
        json.map do |j|
          resolve_refs j, path
        end
      else
        json
      end
    end

    def load_schemas
      ret = {}
      path = File.join('fixtures')
      Dir.glob("#{path}/**/*.json") do |f|
        json = resolve_refs(JSON.parse(File.read(f)), f)
        ret[f] = json
      end
      ret
    end

    def load_endpoints
      file = File.join('fixtures', 'endpoints.json')
      endpoints = JSON.parse(File.read(file))
      endpoints
    end
  end
end