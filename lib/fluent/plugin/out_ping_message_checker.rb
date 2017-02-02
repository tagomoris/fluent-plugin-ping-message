require 'fluent/plugin/output'

class Fluent::Plugin::PingMessageCheckerOutput < Fluent::Plugin::Output
  Fluent::Plugin.register_output('ping_message_checker', self)

  helpers :event_emitter, :timer

  config_param :tag, :string
  config_param :data_field, :string, default: 'data'
  config_param :notifications, :bool, default: true

  config_param :check_interval, :time, default: 3600
  config_param :notification_times, :integer, default: 3
  config_param :exclude_pattern, :string, default: nil

  def configure(conf)
    super
    @exclude_regex = @exclude_pattern ? Regexp.compile(@exclude_pattern) : nil
  end

  def multi_workers_ready?
    true
  end

  def start
    super
    @checks = {}
    # 'data' => notification_counts
    # -1: checked in previous term, but not in this term
    #  0: checked in this term
    # 1,2,...: counts of ping missing notifications
    @mutex = Mutex.new
    timer_execute(:out_ping_messager_chacker_timer, @check_interval) do
      begin
        check_and_flush
      rescue => e
        log.warn "unexpected error", error: e
        log.warn_backtrace
      end
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
    log.warn "unexpected error while processing events", error: e
    log.warn_backtrace
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
end
