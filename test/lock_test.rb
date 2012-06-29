require 'test/unit'
require 'resque'
require 'resque/plugins/lock'

$counter = 0

class Job
  extend Resque::Plugins::Lock
  @queue = :test

  def self.perform
    $counter += 1
    sleep 1
  end
end

class LockTest < Test::Unit::TestCase
  def test_version
    assert_equal '1.20.0', Resque::Version
  end

  def test_lock
    3.times { Resque.enqueue(Job) }
    worker = Resque::Worker.new(:test)

    workers = []
    3.times do
      workers << Thread.new { worker.process }
    end
    workers.each { |t| t.join }

    assert_equal 1, $counter
  end
end
