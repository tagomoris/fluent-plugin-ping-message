require 'fluent/mixin/config_placeholders'

class Fluent::PingMessageInput < Fluent::Input
  Fluent::Plugin.register_input('ping_message', self)

  include Fluent::Mixin::ConfigPlaceholders

  config_param :tag, :string, :default => 'ping'
  config_param :interval, :integer, :default => 60
  config_param :payload, :string, :default => 'ping'

  def start
    super
    start_loop
  end

  def shutdown
    super
    @loop.terminate
    @loop.join
  end

  def start_loop
    @loop = Thread.new(&method(:loop))
  end

  def loop
    @last_checked = Fluent::Engine.now
    while true
      sleep 0.5
      if Fluent::Engine.now - @last_checked >= @interval
        @last_checked = Fluent::Engine.now
        Fluent::Engine.emit(@tag, Fluent::Engine.now, {'payload' => @payload})
      end
    end
  end

end
