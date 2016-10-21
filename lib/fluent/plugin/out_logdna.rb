require 'fluent/output'

module Fluent
  class LogDNAOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('logdna', self)

    INGESTER_DOMAIN = 'https://logs.logdna.com'.freeze
    @ingest_dir = '/logs/ingest'

    config_param :api_key, :string
    config_param :hostname, :string
    config_param :mac, :string, default: nil
    config_param :ip, :string, default: nil
    config_param :app, :string, default: nil

    def configure(conf)
      super
      @host = conf['hostname']
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

      data
    end

    def gather_line_data(tag, time, record)
      line = {
        level: tag.split('.').last,
        timestamp: time,
        line: JSON.generate(record)
      }
      line[:app] = @app if @app
      line
    end

    def handle(response)
      if response.status == 'error'
        print "Error connecting to LogDNA ingester. \n"
        print "Details: #{response}"
      else
        print "Success! #{response}"
      end

      response.flush
    end

    def send_request(body)
      now = Time.now.to_i
      url = "#{@ingest_dir}?hostname=#{@host}&mac=#{@mac}&ip=#{@ip}&now=#{now}"
      print url + "\n"
      @ingester.headers(apikey: @api_key,
                        content_type: 'application/json; charset=UTF-8')
               .post(url, body: JSON.generate(body))
    end
  end
end
