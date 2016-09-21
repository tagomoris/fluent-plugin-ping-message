require 'fluent/plugin/output'
require 'fluent/mixin/config_placeholders'

class Fluent::Plugin::PingMessageCheckerOutput < Fluent::Plugin::Output
  Fluent::Plugin.register_output('ping_message_checker', self)

  helpers :event_emitter, :timer

  config_param :data_field, :string, :default => 'data'

  config_param :tag, :string

  config_param :notifications, :bool, :default => true
  # config_param :report_list, :bool, :default => false # not implemented now

  config_param :check_interval, :integer, :default => 3600
  config_param :notification_times, :integer, :default => 3

  config_param :exclude_pattern, :string, :default => nil

  include Fluent::Mixin::ConfigPlaceholders

  def configure(conf)
    super
    @exclude_regex = @exclude_pattern ? Regexp.compile(@exclude_pattern) : nil
  end

  def start
    super
    @checks = {}
    # 'data' => notification_counts
    # -1: checked in previous term, but not in this term
    #  0: checked in this term
    # 1,2,...: counts of ping missing notifications
    @mutex = Mutex.new
    start_watch
  end

  def shutdown
    super
  end

  def start_watch
    @last_checked = Fluent::Engine.now
    timer_execute(:out_ping_messager_chacker_timer, 1, &method(:watch))
  end

  def update_state(list)
    @mutex.synchronize do
      list.each do |data|
        if not @checks.has_key?(data) or @checks[data] != 0
          @checks[data] = 0
        end
      end
    end
  end

  def check_and_flush
    notifications = []

    @mutex.synchronize do
      @checks.keys.each do |key|
        if @checks[key] == 0
          @checks[key] = -1

        elsif @checks[key] < 0
          notifications.push(key)
          @checks[key] = 1

        else # @checks[key] > 0
          if @checks[key] < @notification_times
            notifications.push(key)
            @checks[key] += 1
          else
            @checks.delete(key)
          end
        end
      end
    end
    
    if @notifications
      notifications.each do |data|
        router.emit(@tag, Fluent::Engine.now, {@data_field => data})
      end
    end

    notifications
  end

  def watch
    begin
      if Fluent::Engine.now - @last_checked >= @check_interval
        check_and_flush()
        @last_checked = Fluent::Engine.now
      end
    rescue => e
      log.warn "out_ping_message_checker: #{e.class} #{e.message} #{e.backtrace.first}"
    end
  end

  def process(tag, es)
    datalist = []
    es.each do |time,record|
      datalist.push record[@data_field] if @exclude_regex.nil? or not @exclude_regex.match(record[@data_field])
    end
    datalist.uniq!
    update_state(datalist)
  rescue => e
    log.warn "out_ping_message_checker: #{e.message} #{e.class} #{e.backtrace.first}"
  end
end
