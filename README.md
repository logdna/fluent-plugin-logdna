# fluent-plugin-logdna

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-logdna.svg)](https://badge.fury.io/rb/fluent-plugin-logdna)

Using fluent-plugin-logdna, you can send the logs you collect with Fluentd to LogDNA.

## Instructions

* Install [Fluentd](http://www.fluentd.org/download)
* `gem install fluent-plugin-logdna` or `td-agent-gem install fluent-plugin-logdna` if you are using td-agent.
* Add the contents below to `/etc/fluent/fluent.conf`. For td-agent, use `/etc/td-agent/td-agent.conf`:

~~~~~
<match your_match>
  @type logdna
  api_key xxxxxxxxxxxxxxxxxxxxxxxxxxx # paste your api key here (required)
  hostname "#{Socket.gethostname}"    # your hostname (required)
  app my_app                          # replace with your app name
  #mac C0:FF:EE:C0:FF:EE              # optional mac address
  #ip 127.0.0.1                       # optional ip address
</match>
~~~~~
* Restart fluentd to pick up the configuration changes.

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

## Additional Options

For advanced configuration options, refer to the [buffered output parameters documentation.](http://docs.fluentd.org/articles/output-plugin-overview#buffered-output-parameters)

Questions or concerns? Contact [support@logdna.com](mailto:support@logdna.com).
