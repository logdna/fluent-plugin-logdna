# fluent-plugin-logdna Gem Version

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-logdna.svg)](https://badge.fury.io/rb/fluent-plugin-logdna)

Using fluent-plugin-logdna, you can send the logs you collect with Fluentd to LogDNA.

## Instructions

* Requirements:
  * `ruby >= 2.3`
  * `fluentd < 2.0`
* Install Fluentd
  * [Download here](http://www.fluentd.org/download)
  * If using fluentd package manager (td-agent): `td-agent-gem install fluent-plugin-logdna`
  * To install without td-agent: `gem install fluent-plugin-logdna`
* Add the config below to `/etc/fluent/fluent.conf`. For `td-agent`, `/etc/td-agent/td-agent.conf`:

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
  - **Default**: `https://logs.logdna.com`
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
  ingester_endpoint /logs/ingest
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


## Building a debian package for td-agent

If you use td-agent you can build a debian package instead of installing via `td-agent-gem`. This requires that td-agent is already installed and that you've installed [fpm](http://fpm.readthedocs.io/en/latest/index.html). Then run `make` in your git directory.

~~~~~bash
gem install --no-document fpm
git clone https://github.com/logdna/fluent-plugin-logdna
cd fluent-plugin-logdna
gem build fluent-plugin-logdna.gemspec
fpm --input-type gem \
    --output-type deb \
    --no-auto-depends \
    --no-gem-fix-name \
    --depends 'td-agent > 2' \
    --deb-build-depends 'td-agent > 2' \
    fluent-plugin-logdna-*.gem
sudo dpkg -i fluent-plugin-logdna*.deb
~~~~~

## Additional Options

For advanced configuration options, please refer to the [buffered output parameters documentation.](https://docs.fluentd.org/v/0.12/output#buffered-output-parameters)

# fluent-plugin-logdna Windows Version

##Install Fluentd

On Windows Server (2008 or newer), install the FluentD’s td-agent [here](https://docs.fluentd.org/installation/install-by-msi#td-agent-v4), or run this command in PowerShell:

```
Invoke-WebRequest -Uri "http://packages.treasuredata.com.s3.amazonaws.com/4/windows/td-agent-4.0.0-x64.msi" -Outfile td-agent.msi ; & .\td-agent.msi /passive
```

##Configure Fluentd

1. Head to where FluentD is installed – by default, it's in `C:\opt\td-agent\etc\td-agent\`

2. Copy and paste [our configuration template](#our-fluentd-configuration) from the end of this page into the existing td-agent.conf file.

3. On the line with `channels, application, system`, you can include one or more of `{'application', 'system', 'setup', 'security'}`. If you want to read 'setup' or 'security' logs, you must launch FluentD with administrator privileges.

4. On the `api_key` line, replace the filler text with your LogDNA ingestion key.

5. On the `ingester_domain` line, replace the URL if you are not using our default ingestion endpoint.

6. Finally, save the changes you've made to your td-agent.conf file.


##Install the [LogDNA Fluentd plugin](https://github.com/logdna/fluent-plugin-logdna)

Run this command in PowerShell

```
Start-Process cmd "/c C:\opt\td-agent\bin\td-agent-gem install fluent-plugin-logdna"
```

##Start FluentD

Run this command in PowerShell
```
Start-Process cmd "/k C:\opt\td-agent\td-agent-prompt.bat && fluentd -c c:\opt\td-agent\etc\td-agent\td-agent.conf"
```

Now, check your LogDNA account to see that it’s sending logs.

If logs aren’t showing up in your account, check the td-agent prompt to see what the configuration problem might be. Please contact [support@logdna.com](mailto:support@logdna.com), and let us know what you see.

##Our FluentD Configuration

```
<source>
  @type windows_eventlog2
  @id windows_eventlog2
  channels application,system # Also be able to use `<subscribe>` directive.
  read_existing_events false
  read_interval 2
  tag winevt.raw
  render_as_xml true   	# default is false.
  rate_limit 200        	# default is -1(Winevt::EventLog::Subscribe::RATE_INFINITE).
  # preserve_qualifiers_on_hash true # default is false.
  # read_all_channels false # default is false.
  # description_locale en_US # default is nil. It means that system locale is used for obtaining description.
  <storage>
	@type local         	# @type local is the default.
	persistent true     	# default is true. Set to false to use in-memory storage.
	path ./tmp/storage.json # This is required when persistent is true.
                        	# Or, please consider using <system> section's `root_dir` parameter.
  </storage>
  <parse>
	@type winevt_xml # @type winevt_xml is the default. winevt_xml and none parsers are supported for now.
	# When set up it as true, this plugin preserves "Qualifiers" and "EventID" keys.
	# When set up it as false, this plugin calculates actual "EventID" from "Qualifiers" and removing "Qualifiers".
	# With the following equation:
	# (EventID & 0xffff) | (Qualifiers & 0xffff) << 16
	preserve_qualifiers true
  </parse>
  # <subscribe>
  #   channels, application, system
  #   read_existing_events false # read_existing_events should be applied each of subscribe directive(s)
  # </subscribe>
</source>
 
<match **>
  @type logdna
  api_key xxxxxxxxxxxxxxxxxxxxxxxxxxx	# paste your api key here (required)
  ingester_domain https://logs.logdna.com	#Replace with your specific LogDNA endpoint
  hostname "#{Socket.gethostname}"		#your hostname (required)
  app my_app                   			# replace with your app name
  #mac C0:FF:EE:C0:FF:EE                 	# optional mac address
  #ip 127.0.0.1                          		# optional ip address
  #tags web,dev                          		# optional tags
  slow_flush_log_threshold 30.0
  request_timeout 30000 ms               	# optional timeout for upload request, supports seconds (s, default) and milliseconds (ms) suffixes, default 30 seconds
  buffer_chunk_limit 1m                  		# do not increase past 8m (8MB) or your logs will be rejected by our server.
  flush_at_shutdown true                 		# only needed with file buffer
</match>


Questions or concerns? Contact [support@logdna.com](mailto:support@logdna.com).

Contributions are always welcome. See the [contributing guide](/CONTRIBUTING.md) to learn how you can help.
