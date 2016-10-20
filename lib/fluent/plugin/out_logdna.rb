require 'json'
require 'fluent/output'
require 'http'

module Fluent
  class LogDNAOutput < BufferedOutput
    INGESTER_DOMAIN = 'https://logs.logdna.com'.freeze
    INGESTER_URL = '/logs/ingest'.freeze

    Fluent::Plugin.register_output('logdna', self)

    config_param :api_key, :string
    config_param :hostname, :string
    config_param :mac, :string, default: nil
    config_param :ip, :string, default: nil
    config_param :app, :string, default: nil

    def configure(conf)
      super
    end

    def start
      super
      @ingester = HTTP.persistent INGESTER_DOMAIN
    end

    def shutdown
      super
      ingester.close if ingester
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      body = chunk_to_body(chunk)
      response = send_request(body)
      handle(response)
    end

    private

    def chunk_to_body(chunk)
      data = []

      chunk.msgpack_each do |(tag, time, record)|
        line = { level: tag, timestamp: time, line: record }
        line[:app] = @app if @app
        data << line
      end

      data
    end

    def handle(response)
      if response.code >= 400
        print 'Error connecting to LogDNA ingester. Check hostname.\n'
        print "Details: #{response}"
      end

      response.flush
    end

    def send_request(body)
      @ingester.basic_auth(apikey: @api_key)
               .headers(content_type: 'application/json; charset=UTF-8')
               .post(INGESTER_URL,
                     params: {
                       hostname: @hostname,
                       mac: @mac,
                       ip: @ip,
                       now: Time.now.to_i
                     },
                     body: JSON.generate(body))
    end
  end
end
