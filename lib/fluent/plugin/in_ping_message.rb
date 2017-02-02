require 'fluent/plugin/input'
require 'socket'

class Fluent::Plugin::PingMessageInput < Fluent::Plugin::Input
  Fluent::Plugin.register_input('ping_message', self)

  helpers :timer, :inject

  config_param :tag, :string, default: 'ping'
  config_param :interval, :integer, default: 60
  config_param :data, :string, default: Socket.gethostname
  config_param :hostname, :string, default: nil

  def configure(conf)
    super

    if @data.include?('${hostname}')
      @hostname ||= Socket.gethostname
      @data.gsub!('${hostname}', @hostname)
    end
  end

  def multi_workers_ready?
    true
  end

  def start
    super
    timer_execute(:in_ping_message_pingpong, @interval) do
      now = Fluent::Engine.now
      record = inject_values_to_record(@tag, now, {'data' => @data})
      router.emit(@tag, now, record)
    end
  end
end
