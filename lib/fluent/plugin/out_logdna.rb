require 'fluent/output'

module Fluent
  class LogDNAOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('logdna', self)

    INGESTER_DOMAIN = 'https://logs.logdna.com'.freeze
    INGESTER_URL = '/logs/ingest'.freeze

    config_param :api_key, :string
    config_param :hostname, :string
    config_param :mac, :string, default: nil
    config_param :ip, :string, default: nil
    config_param :app, :string, default: nil

    def configure(conf)
      super
      @conf = conf
      @api_key = conf['api_key']
      @hostname = conf['hostname']
      @mac = conf['mac']
      @ip = conf['ip']
      @app = conf['app']
    end

    def start
      super
      require 'json'
      require 'http'
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
      print @conf, @api_key, @hostname, @mac, @ip, @app
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

      print data

      data
    end

    def handle(response)
      if response.code >= 400
        print 'Error connecting to LogDNA ingester. Check hostname.\n'
        print "Details: #{response}"
      else
        print "Success! #{response}"
      end

      response.flush
    end

    def send_request(body)
      @ingester.headers(apikey: @api_key,
                        content_type: 'application/json; charset=UTF-8')
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
