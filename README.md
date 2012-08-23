# fluent-plugin-ping-message

Fluentd plugin to generate ping messages for monitoring of heatbeats.

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

## TODO

* 'PingMessageWatchdogOutput'
  * accepts ping messages and notify hosts ping messages cannot be found

## Copyright

* Copyright
  * Copyright (c) 2012- TAGOMORI Satoshi (tagomoris)
* License
  * Apache License, Version 2.0
