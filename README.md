# fluent-plugin-logdna

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-logdna.svg)](https://badge.fury.io/rb/fluent-plugin-logdna)

Using fluent-plugin-logdna, you can send the logs you collect with Fluentd to LogDNA.

## Instructions

* Install Fluentd
  * [Download here](http://www.fluentd.org/download)
  * If using fluentd package manager (td-agent): `td-agent-gem install fluent-plugin-logdna`
  * To install without td-agent: `gem install fluent-plugin-logdna`
* Add the config below to `/etc/fluent/fluent.conf`. For td-agent, `/etc/td-agent/td-agent.conf`:

## Configuration

### Configuration Parameters
- `api_key`: [Ingestion Key](https://docs.logdna.com/docs/ingestion-key), *Required*
- `hostname`: Hostname, *Required*
- `app`: App Name, *Optional*
- `mac`: MAC Address, *Optional*
- `ip`: IP Address, *Optional*
- `tags`: Comma-Separated List of Tags, *Optional*
- `request_timeout`: HTTPS POST Request Timeout, *Optional*
  - **Note**: Supports `s` and `ms` Suffices
  - **Default**: `30 s`
- `ingester_domain`: Custom Ingester URL, *Optional*
  - **Default**: `htttps://logs.logdna.com`
- `ingester_endpoint`: Custom Ingester Endpoint, *Optional*
  - **Default**: `/logs/ingest`

### Sample Configuration

~~~~~configuration
<match **>
  @type logdna
  api_key xxxxxxxxxxxxxxxxxxxxxxxxxxx
  hostname "#{Socket.gethostname}"
  app my_app
  mac C0:FF:EE:C0:FF:EE
  ip 127.0.0.1
  tags web,dev
  request_timeout 30000 ms
  ingester_domain https://logs.logdna.com
</match>
~~~~~

## Line Parameters

The following line parameters can be set to the information coming from each `record` object:
- `level`: [Level](https://github.com/logdna/logger-node#supported-log-levels): `record['level']` or `record['severity']` or the last `tag` given in each `record`
- `file`: File Name: set to `file` given in each `record`
- `app`: App Name: set to either `_app` or `app` given in each `record`
  - **Default**: `app` given in the configuration
- `env`: Environment Name: set to `env` given in each `record`
- `meta`: Meta Object: set to `meta` given in each `record`

### LogDNA Pay-per-gig Pricing

Our [paid plans](https://logdna.com/pricing/) start at $1.25/GB per month, and it's based only on usage.  There are no fixed data buckets and all paid plans include all features.

## Building a debian package for td-agent

If you use td-agent you can build a debian package instead of installing via `td-agent-gem`. This requires that td-agent is already installed and that you've installed [fpm](http://fpm.readthedocs.io/en/latest/index.html). Then run `make` in your git directory.

~~~~~bash
gem install --no-document fpm
git clone https://github.com/logdna/fluent-plugin-logdna
cd fluent-plugin-logdna
gem build fluent-plugin-logdna.gemspec
fpm --input-type gem --output-type deb \
    --no-auto-depends \
    --no-gem-fix-name \
    --depends 'td-agent > 2' \
    --deb-build-depends 'td-agent > 2' \
    fluent-plugin-logdna-*.gem
sudo dpkg -i fluent-plugin-logdna*.deb
~~~~~

## Additional Options

For advanced configuration options, please refer to the [buffered output parameters documentation.](https://docs.fluentd.org/v/0.12/output#buffered-output-parameters)

Questions or concerns? Contact [support@logdna.com](mailto:support@logdna.com).

Contributions are always welcome. See the [contributing guide](/CONTRIBUTING.md) to learn how you can help.
