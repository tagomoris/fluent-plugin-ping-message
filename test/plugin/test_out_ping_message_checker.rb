require 'helper'

class PingMessageCheckerOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    tag ping.message.checker
  ]

  def create_driver(conf = CONFIG, tag='test.input')
    Fluent::Test::OutputTestDriver.new(Fluent::PingMessageCheckerOutput, tag).configure(conf)
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
    d1 = create_driver(CONFIG, 'ping.webserver')
    flushed = nil
    d1.run do
      d1.emit({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed

      d1.emit({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed
    end
  end

  def test_missing_emit
    d1 = create_driver(CONFIG, 'ping.webserver')
    flushed = nil
    d1.run do
      d1.emit({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed

      flushed = d1.instance.check_and_flush
      assert_equal 'your.hostname.local', flushed.first
    end
  end

  def test_notification_times
    d1 = create_driver(CONFIG + %[notification_times 3], 'ping.webserver')
    flushed = nil
    d1.run do
      d1.emit({'data' => 'your.hostname.local'})
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
    d1 = create_driver(CONFIG + %[notification_times 3], 'ping.webserver')
    flushed = nil
    d1.run do
      d1.emit({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed

      flushed = d1.instance.check_and_flush
      assert_equal 'your.hostname.local', flushed.first

      flushed = d1.instance.check_and_flush
      assert_equal 'your.hostname.local', flushed.first

      d1.emit({'data' => 'your.hostname.local'})
      flushed = d1.instance.check_and_flush
      assert_equal [], flushed
    end
  end
end
