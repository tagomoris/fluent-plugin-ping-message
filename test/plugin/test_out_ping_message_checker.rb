require 'helper'
require 'fluent/test/driver/output'

class PingMessageCheckerOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    tag ping.message.checker
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::PingMessageCheckerOutput).configure(conf)
  end

  def test_configure
    assert_nothing_raised {
      d = create_driver(CONFIG)
    }
    assert_raise(Fluent::ConfigError) {
      d = create_driver('')
    }
  end

  def test_found_not_emit
    d1 = create_driver(CONFIG)
    flushed = nil
    d1.run(default_tag: 'ping.webserver') do
      d1.feed({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed

      d1.feed({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed
    end
  end

  def test_missing_emit
    d1 = create_driver(CONFIG)
    flushed = nil
    d1.run(default_tag: 'ping.webserver') do
      d1.feed({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed

      flushed = d1.instance.check_and_flush
      assert_equal 'your.hostname.local', flushed.first
    end
  end

  def test_notification_times
    d1 = create_driver(CONFIG + %[notification_times 3])
    flushed = nil
    d1.run(default_tag: 'ping.webserver') do
      d1.feed({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed

      flushed = d1.instance.check_and_flush
      assert_equal 'your.hostname.local', flushed.first

      flushed = d1.instance.check_and_flush
      assert_equal 'your.hostname.local', flushed.first

      flushed = d1.instance.check_and_flush
      assert_equal 'your.hostname.local', flushed.first

      flushed = d1.instance.check_and_flush
      assert_equal [], flushed
    end
  end

  def test_recovery
    d1 = create_driver(CONFIG + %[notification_times 3])
    flushed = nil
    d1.run(default_tag: 'ping.webserver') do
      d1.feed({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed

      flushed = d1.instance.check_and_flush
      assert_equal 'your.hostname.local', flushed.first

      flushed = d1.instance.check_and_flush
      assert_equal 'your.hostname.local', flushed.first

      d1.feed({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed
    end
  end
end
