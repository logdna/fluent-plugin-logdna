require 'fluent/output'

module Fluent
  class LogDNAOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('logdna', self)

    INGESTER_DOMAIN = 'https://logs.logdna.com'.freeze
    MAX_RETRIES = 5

    config_param :api_key, :string, secret: true
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
      require 'base64'
      require 'http'
      HTTP.default_options = { :keep_alive_timeout => 60 }
      @ingester = HTTP.persistent INGESTER_DOMAIN
      @requests = Queue.new
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
      raise 'Encountered server error' if response.code >= 400
      response.flush
    end

    private

    def chunk_to_body(chunk)
      data = []

      chunk.msgpack_each do |(tag, time, record)|
        line = gather_line_data(tag, time, record)
        data << line unless line[:line].empty?
      end

      { lines: data }
    end

    def gather_line_data(tag, time, record)
      line = {
        level: record['level'] || record['severity'] || tag.split('.').last,
        timestamp: time,
        line: record['message'] || record.to_json
      }
      line[:app] = record['_app'] || record['app']
      line[:app] ||= @app if @app
      line.delete(:app) if line[:app].nil?
      line[:meta] = record['meta']
      line[:meta] ||= @meta if @meta
      line.delete(:meta) if line[:meta].nil?
      line
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
