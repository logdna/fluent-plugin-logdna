require 'fluent/output'

module Fluent
  class LogDNAOutput < BufferedOutput
    INGESTER_URL = 'https://logs.logdna.com/logs/ingest'

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
      require 'http'
      require 'json'
      @app = conf['app']
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      data = []

      chunk.msgpack_each do |(tag, time, record)|
        line = {
          level: tag,
          timestamp: time,
          line: record
        }
        line[:app] = @app if @app
        data << line
      end

      response = HTTP.basic_auth(apikey: conf['api_key'])
        .headers(content_type: 'application/json; charset=UTF-8')
        .post(INGESTER_URL, {
          params: {
            hostname: conf['hostname'],
            mac: conf['mac'],
            ip: conf['ip'],
            now: Time.now.to_i
          },
          body: JSON.generate(data)
        })

      if response.code >= 400
        print 'Error connecting to LogDNA ingester. Check hostname.\n'
        print "Details: #{response.to_s}"
      end
    end
  end
end