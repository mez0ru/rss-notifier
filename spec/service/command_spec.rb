# frozen_string_literal: true

require_relative 'spec_helper'
require 'logger'

describe CommandService do
  it 'Command service should work' do
    pu_count = PastUpdate.count

    # Mocks
    Thread.expects(:new).at_least(2).yields
    Open3.expects(:capture3).with("ruby \"#{__dir__}/command_dummy_test.rb\" \"test\" 0").once.returns(['test', 'test', stub(success?: true, exitstatus: 0)])
    Open3.expects(:capture3).with("ruby \"#{__dir__}/command_dummy_test.rb\" \"test\" 1").once.returns(['test', 'test', stub(success?: false, exitstatus: 1)])

    _command = CommandService.new(
      "ruby \"#{__dir__}/command_dummy_test.rb\" \"%url%\" 0",
      Logger.new($stdout)
    )

    _command.queued = [
      {
        name: 'test',
        thumbnail: 'test',
        url: 'test',
        title: 'test',
        published: DateTime.now,
        is_published: true,
        feed_id: 1
      }
    ]

    _command.start

    PastUpdate.count.must_equal(pu_count + 1, 'Past update did not get created...')
    Log.last.level.must_equal('info', 'Log level should be info if successful...')
    # while _command.running?
    #   sleep 0.1
    # end

    assert_empty(_command.queued, 'Successful Command queues are not empty...')
    assert_empty(_command.running, 'Successful Command running are not empty...')

    puts "Testing second command"
    _command = CommandService.new(
      "ruby \"#{__dir__}/command_dummy_test.rb\" \"%url%\" 1",
      Logger.new($stdout)
    )
    _command.queued = [
      {
        name: 'test',
        thumbnail: 'test',
        url: 'test',
        title: 'test',
        published: DateTime.now,
        is_published: true,
        feed_id: 1
      }
    ]
    _command.start
    # while _command.running?
    #   sleep 0.1
    # end

    PastUpdate.count.must_equal(pu_count + 1, 'Past update should not be created if error...')
    Log.last.level.must_equal('error', 'Log level should be error if unsuccessful...')

    assert_empty(_command.queued, 'Error Command queues are not empty...')
    assert_empty(_command.running, 'Error Command running are not empty...')
  end
end
