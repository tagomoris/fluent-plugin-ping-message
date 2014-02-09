# fluent-plugin-ping-message

[Fluentd](http://fluentd.org) plugins:

* to generate ping messages for monitoring of heatbeats
* to check ping messages not arrived, and emits notifications

## Configuration

### PingMessageInput

To generate 1 ping message per 60seconds(default):

    <source>
      type ping_message
    </source>
    #=> tag: 'ping'
    #   message: {'data' => 'your.hostname.local'}

Change ping message interval into 30 seconds, and fix tag and 'data':

    <source>
      type ping_message
      tag ping.webserver
      interval 30
      data ping message from ${hostname}
    </source>
    #=> tag: 'ping.webserver'
    #   message: {'data' => 'ping message from your.hostname.local'}

### PingMessageCheckerOutput

To receive ping messages and checks ping message in-arrival, use `type ping_message_checker`:

    <match ping.**>
      type ping_message_checker
      tag missing.ping
      check_interval  3600   # 1hour by default
      notification_times 3   # 3 times by default
    </match>

With this configuration, this plugin save the list of ping messages' 'data' field values. And then, at the time of ping message missing, notification message emitted with `tag`.

## TODO

* add feature to output ping messages list
* patches welcome!

## Copyright

* Copyright
  * Copyright (c) 2012- TAGOMORI Satoshi (tagomoris)
* License
  * Apache License, Version 2.0
