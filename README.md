# fluent-plugin-ping-message

[Fluentd](http://fluentd.org) plugins:

* to generate ping messages for monitoring of heatbeats
* to check ping messages not arrived, and emits notifications

## Requirements

| fluent-plugin-ping-message | fluentd    | ruby   |
|----------------------------|------------|--------|
| >= 1.0.0                   | >= v0.14.0 | >= 2.1 |
| < 1.0.0                    | >= v0.12.0 | >= 1.9 |

## Configuration

### PingMessageInput

To generate 1 ping message per 60seconds(default):

    <source>
      @type ping_message
      @label @heartbeat_events
    </source>
    
    <label @heartbeat_events>
      #=> tag: 'ping'
      #   message: {'data' => 'your.hostname.local'}
      <match ping>
        # send hosts w/ ping_message_checker
      </match>
    </label>

Change ping message interval into 30 seconds, and fix `tag` and `data`:

    <source>
      @type ping_message
      @label @heartbeat_events
      tag ping.webserver
      interval 30
      data ping message from ${hostname}
    </source>
    
    <label @heartbeat_events>
      #=> tag: 'ping.webserver'
      #   message: {'data' => 'ping message from your.hostname.local'}
    </label>

`<inject>` section is available to include hostname key or timestamp (unixtime, float or string).

    <source>
      @type ping_message
      @label @heartbeat_events
      tag      ping
      interval 30
      data     "this is ping message"
      <inject>
        hostname_key host     # {"host": "my.hostname.example.com"}
        time_key     time
        time_type    unixtime # {"time": 1486014439}
      </inject>
    </source>

Example using string time format in specified time zone:

    <source>
      @type ping_message
      @label @heartbeat_events
      tag      ping
      interval 30
      data     "this is ping message"
      <inject>
        hostname_key host     # {"host": "my.hostname.example.com"}
        time_key     time
        time_type    string
        time_format  "%Y-%m-%d %H:%M:%S" # {"time": "2017-02-01 14:50:38"}
        timezone     -0700    # or "localtime yes" / "localtime no" (UTC), ...
      </inject>
    </source>

### PingMessageCheckerOutput

To receive ping messages and checks ping message in-arrival, use `@type ping_message_checker`:

    <match ping.**>
      @type ping_message_checker
      tag missing.ping
      check_interval  3600   # 1hour by default
      notification_times 3   # 3 times by default
    </match>

With this configuration, this plugin save the list of ping messages' `data` field values. And then, at the time of ping message missing, notification message emitted with the specified `tag` and record like `{"data": "failing.hostname.local"}`.

## TODO

* patches welcome!

## Copyright

* Copyright
  * Copyright (c) 2012- TAGOMORI Satoshi (tagomoris)
* License
  * Apache License, Version 2.0
