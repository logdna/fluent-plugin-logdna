# fluent-plugin-logdna

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-logdna.svg)](https://badge.fury.io/rb/fluent-plugin-logdna)

Using fluent-plugin-logdna, you can send the logs you collect with Fluentd to LogDNA.

## Instructions

* Install [Fluentd](http://www.fluentd.org/download)
* `gem install fluent-plugin-logdna` or `td-agent-gem install fluent-plugin-logdna` if you are using td-agent.
* Make sure you have a LogDNA account.
* Configure Fluentd like the following:

~~~~~
<match your_match>
  type logdna
  api_key d942fed2d0a65b0181e49ae3307465dd # paste your api key here (required)
  hostname GitHub                          # replace with your hostname (required)
  mac C0:FF:EE:C0:FF:EE                    # replace with host mac address
  ip 127.0.0.1                             # replace with host ip address
  app my_app                               # replace with your app name
</match>
~~~~~

For advanced configuration options, refer to the [buffered output parameters documentation.](http://docs.fluentd.org/articles/output-plugin-overview#buffered-output-parameters)

Questions or concerns? Contact [support@logdna.com](mailto:support@logdna.com).
