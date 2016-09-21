require 'fluent/plugin/input'
require 'fluent/mixin/config_placeholders'

class Fluent::Plugin::PingMessageInput < Fluent::Plugin::Input
  Fluent::Plugin.register_input('ping_message', self)

  helpers :timer

  # Define `log` method for v0.10.42 or earlier
  unless method_defined?(:log)
    define_method("log") { $log }
  end

  include Fluent::Mixin::ConfigPlaceholders

  config_param :tag, :string, :default => 'ping'
  config_param :interval, :integer, :default => 60
  config_param :data, :string, :default => `hostname`.chomp

  # Define `router` method of v0.12 to support v0.10.57 or earlier
  unless method_defined?(:router)
    define_method("router") { Fluent::Engine }
  end

  def start
    super
    start_pingloop
  end

  def shutdown
    super
  end

  def start_pingloop
    @last_checked = Fluent::Engine.now
    timer_execute(:in_ping_message_pingpong, 0.5, &method(:pingloop))
  end

  def pingloop
    if Fluent::Engine.now - @last_checked >= @interval
      @last_checked = Fluent::Engine.now
      router.emit(@tag, Fluent::Engine.now, {'data' => @data})
    end
  end
end
