# fluent-plugin-logdna

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-logdna.svg)](https://badge.fury.io/rb/fluent-plugin-logdna)

Using fluent-plugin-logdna, you can send the logs you collect with Fluentd to LogDNA.

## Instructions

* Install [Fluentd](http://www.fluentd.org/download)
* Alternative install if using fluentd package manager (td-agent): `td-agent-gem install fluent-plugin-logdna`
* Add the contents below to `/etc/fluent/fluent.conf`. For td-agent, use `/etc/td-agent/td-agent.conf`:
* Alternative install without td-agent is: `gem install fluent-plugin-logdna` 

~~~~~
<match **>
  @type logdna
  api_key xxxxxxxxxxxxxxxxxxxxxxxxxxx        # paste your api key here (required)
  hostname "#{Socket.gethostname}"           # your hostname (required)
  app my_app                                 # replace with your app name
  #mac C0:FF:EE:C0:FF:EE                     # optional mac address
  #ip 127.0.0.1                              # optional ip address
  proxy_host myproxyserver                   # optional forward proxy host
  proxy_port 8080                            # optional forward proxy port, default 8080
  buffer_chunk_limit 1m                      # do not increase past 8m (8MB) or your logs will be rejected by our server.
  flush_at_shutdown true                     # only needed with file buffer
</match>
~~~~~
* Restart fluentd to pick up the configuration changes.
* `sudo /etc/init.d/td-agent stop`
* `sudo /etc/init.d/td-agent start`

### Recommended Configuration Parameters

* buffer_type
  - We recommend setting this to memory for development and file for production (file setting requires a buffer_path).
* buffer_queue_limit, buffer_chunk_limit
  - We do not recommend increasing buffer_chunk_limit past 8MB.
* flush_interval
  - Default is 60s. We recommend keeping this well above 5s.
* retry_wait, max_retry_wait, retry_limit, disable_retry_limit
  - We recommend increasing these values if you are encountering problems.

### Options

* App name and log level can also be provided on a line-by-line basis over JSON:
* `_app` and `level` will override the config

If you don't have a LogDNA account, you can create one on https://logdna.com or if you're on macOS w/[Homebrew](https://brew.sh) installed:

```
brew cask install logdna-cli
logdna register <email>
# now paste the api key above
```

### LogDNA Pay-per-gig Pricing

Our [paid plans](https://logdna.com/#pricing) start at $1.25/GB per month, pay for what you use / no fixed data buckets / all paid plans include all features.

## Building a debian package for td-agent
If you use td-agent you can build a debian package instead of installing via
td-agent-gem. This requires that td-agent is already installed and that you've
installed [fpm](http://fpm.readthedocs.io/en/latest/index.html). Then just run
`make` in your git directory.

```
gem install --no-ri --no-rdoc fpm
git clone https://github.com/logdna/fluent-plugin-logdna
cd fluent-plugin-logdna
make
sudo dpkg -i fluent-plugin-logdna*.deb
```

## Additional Options

For advanced configuration options, please refer to the [buffered output parameters documentation.](http://docs.fluentd.org/articles/output-plugin-overview#buffered-output-parameters)

Questions or concerns? Contact [support@logdna.com](mailto:support@logdna.com).
