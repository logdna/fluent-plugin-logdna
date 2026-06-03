# frozen_string_literal: true

# https://docs.fluentd.org/plugin-development/api-plugin-output#how-to-write-tests

require_relative "../helper"
require "fluent/test/driver/output"
require "fluent/plugin/out_stdout"
require "fluent/plugin/input"
require "webmock/test_unit"

require "lib/fluent/plugin/out_logdna.rb"

class LogdnaOutputTest < Test::Unit::TestCase
  include WebMock::API

  def setup
    Fluent::Test.setup

    stub_request(:post, %r{logs.logdna.com/logs/ingest})
  end

  # default configuration for tests
  CONFIG = %(
    api_key this-is-my-key
    hostname "localhost"
    app my_app
    mac C0:FF:EE:C0:FF:EE
    ip 127.0.0.1
    tags  "my-tag"
  )

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::LogDNAOutput).configure(conf)
  end

  test "instantiate the plugin and check default config values" do
    d = create_driver

    # check defaults
    assert_equal "https://logs.logdna.com", d.instance.ingester_domain
    assert_equal 30, d.instance.request_timeout
    assert_equal 8 * 1024 * 1024, d.instance.payload_size
  end

  test "instantiate the plugin and check setting config values" do
    conf = %(
          api_key this-is-my-key
          hostname "localhost"
          app my_app
          mac C0:FF:EE:C0:FF:EE
          ip 127.0.0.1
          tags  "my-tag"
          request_timeout 17s
          ingester_endpoint this/is/my/alternate/endpoint
      )

    d = create_driver(conf)

    # check set config values
    assert_equal "my-tag", d.instance.tags
    assert_equal 17, d.instance.request_timeout
    assert_equal "this/is/my/alternate/endpoint", d.instance.ingester_endpoint
  end

  test "instantiate the plugin with ms request_timeout value" do
    conf = %(
          api_key this-is-my-key
          hostname "localhost"
          app my_app
          mac C0:FF:EE:C0:FF:EE
          ip 127.0.0.1
          tags  "my-tag"
          request_timeout 17000 ms
      )

    d = create_driver(conf)

    # check set config values
    assert_equal 17, d.instance.request_timeout
  end

  test "instantiate the plugin with nonesense request_timeout value" do
    conf = %(
          api_key this-is-my-key
          hostname "localhost"
          app my_app
          mac C0:FF:EE:C0:FF:EE
          ip 127.0.0.1
          tags  "my-tag"
          request_timeout "asdf ms"
      )

    d = create_driver(conf)

    # check set config values
    assert_equal 30, d.instance.request_timeout
  end

  test "simple #write" do
    d = create_driver
    time = event_time

    d.run do
      d.feed("output.test", time, { "foo" => "bar", "message" => "myLine" })
      d.feed("output.test", time, { "foo" => "bar", "message" => "myLine" })
    end

    assert_equal(2, d.formatted.size)
  end

  test "chunk_to_bodies splits into multiple payloads when payload_size is exceeded" do
    conf = CONFIG + "\npayload_size 10"
    d = create_driver(conf)

    assert_equal 10, d.instance.payload_size

    time = event_time
    record = { "foo" => "bar", "message" => "myLine" }
    lines = [
      d.instance.send(:gather_line_data, "output.test", time, record),
      d.instance.send(:gather_line_data, "output.test", time, record),
      d.instance.send(:gather_line_data, "output.test", time, record)
    ]

    # Simulate a chunk by building a fake object that yields the lines
    fake_chunk = Object.new
    fake_chunk.define_singleton_method(:msgpack_each) do |&block|
      lines.each { |l| block.call(["output.test", time, record]) }
    end

    bodies = d.instance.send(:chunk_to_bodies, fake_chunk)
    assert bodies.length > 1, "Expected multiple bodies due to small payload_size"
    bodies.each { |b| assert b[:lines].length >= 1 }
  end

  test "chunk_to_bodies returns a single payload when within payload_size" do
    d = create_driver
    time = event_time
    record = { "foo" => "bar", "message" => "myLine" }

    fake_chunk = Object.new
    fake_chunk.define_singleton_method(:msgpack_each) do |&block|
      3.times { block.call(["output.test", time, record]) }
    end

    bodies = d.instance.send(:chunk_to_bodies, fake_chunk)
    assert_equal 1, bodies.length
    assert_equal 3, bodies.first[:lines].length
  end
end
