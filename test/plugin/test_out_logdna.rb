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
end
