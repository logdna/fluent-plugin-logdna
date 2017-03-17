require 'fluent/output'

module Fluent
  class LogDNAOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('logdna', self)

    INGESTER_DOMAIN = 'https://logs.logdna.com'.freeze

    config_param :api_key, :string, secret: true
    config_param :hostname, :string
    config_param :mac, :string, default: nil
    config_param :ip, :string, default: nil
    config_param :app, :string, default: nil
    config_param :level_field, :string, default: 'level'

    def configure(conf)
      super
      @host = conf['hostname']
    end

    def start
      super
      require 'json'
      require 'base64'
      require 'http'
      @ingester = HTTP.persistent INGESTER_DOMAIN
    end

    def shutdown
      super
      @ingester.close if @ingester
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
        line = gather_line_data(tag, time, record)
        data << line
      end

      { lines: data }
    end

    def gather_line_data(tag, time, record)
      line = {
        level: record[@level_field] || info,
        timestamp: time,
        line: record.to_json
      }
      line[:app] = record['_app'] || record['app']
      line[:app] ||= @app if @app
      line.delete(:app) if line[:app].nil?
      line
    end

    def handle(response)
      if response.code >= 400
        print "Error connecting to LogDNA ingester. \n"
        print "Details: #{response}"
      else
        print "Success! #{response}"
      end

      response.flush
    end

    def send_request(body)
      now = Time.now.to_i
      url = "/logs/ingest?hostname=#{@host}&mac=#{@mac}&ip=#{@ip}&now=#{now}"
      @ingester.headers('apikey' => @api_key,
                        'content-type' => 'application/json')
               .post(url, json: body)
    end
  end
end
