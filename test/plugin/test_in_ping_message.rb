require 'helper'
require 'fluent/test/driver/input'

class PingMessageCheckerInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    tag ping.message
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::PingMessageInput).configure(conf)
  end

  def test_configure
    assert_nothing_raised {
      create_driver(CONFIG)
    }
    assert_nothing_raised {
      create_driver('')
    }
  end
end
