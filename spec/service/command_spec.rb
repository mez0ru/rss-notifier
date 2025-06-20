# frozen_string_literal: true

require_relative 'spec_helper'
require 'logger'

describe CommandService do
  it 'Command service should work' do
    # Test successful commands
    pu_count = PastUpdate.count
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
    while _command.running?
      sleep 0.1
    end

    puts "Testing second command"
    # _command = CommandService.new(
    #   "ruby \"#{__dir__}/command_dummy_test.rb\" \"%url%\" 1",
    #   Logger.new($stdout)
    # )
    # _command.queued = [
    #   {
    #     name: 'test',
    #     thumbnail: 'test',
    #     url: 'test',
    #     title: 'test',
    #     published: DateTime.now,
    #     is_published: true,
    #     feed_id: 1
    #   }
    # ]
    # _command.start
    # while _command.running?
    #   sleep 0.1
    # end
    #
    # PastUpdate.count.must_equal(pu_count + 1)
    # Log.last.level.must_equal('error')
    #
    # assert_empty(_command.queued, 'Command queues are not empty...')
    # assert_empty(_command.running, 'Command running are not empty...')
    

    # command = CommandService.new(command: "ruby \"#{__dir__}/command_dummy_test.rb\" \"%url%\" 0", logger: Logger.new($stdout))
    #
    # refute_nil(feed_service.queued, 'Queued feeds are nil...')
    # refute_empty(feed_service.queued, 'There should be queued feeds, but there\'s none...')
    #
    # feed_service.queued.each do |feed|
    #   refute_nil(feed[:name], 'Queued name is nil.')
    #   refute_empty(feed[:name], 'Queued name is empty.')
    #   refute_nil(feed[:thumbnail], 'Queued thumbnail is nil.')
    #   refute_empty(feed[:thumbnail], 'Queued thumbnail is empty.')
    #   refute_nil(feed[:url], 'Queued url is nil.')
    #   refute_empty(feed[:url], 'Queued url is empty.')
    #   refute_nil(feed[:title], 'Queued title is nil.')
    #   refute_empty(feed[:title], 'Queued title is empty.')
    #   refute_nil(feed[:published], 'Queued published is nil.')
    #   refute_empty(feed[:published], 'Queued published is empty.')
    #   refute_nil(feed[:is_published], 'Queued is_published is nil.')
    #   assert_includes([true, false], feed[:is_published], 'Queued is_published is not boolean.')
    # end
    #
    # refute_nil(feed_service.latest, 'Latest feeds are nil...')
    # refute_empty(feed_service.latest, 'There should be latest feeds, but there\'s none...')
    # feed_service.latest.each do |feed|
    #   refute_nil(feed[:name], 'Latest name is nil.')
    #   refute_empty(feed[:name], 'Latest name is empty.')
    #   refute_nil(feed[:thumbnail], 'Latest thumbnail is nil.')
    #   refute_empty(feed[:thumbnail], 'Latest thumbnail is empty.')
    #   refute_nil(feed[:url], 'Latest url is nil.')
    #   refute_empty(feed[:url], 'Latest url is empty.')
    #   refute_nil(feed[:title], 'Latest title is nil.')
    #   refute_empty(feed[:title], 'Latest title is empty.')
    #   refute_nil(feed[:published], 'Latest published is nil.')
    #   refute_empty(feed[:published], 'Latest published is empty.')
    #   refute_nil(feed[:is_published], 'Latest is_published is nil.')
    #   assert_includes([true, false], feed[:is_published], 'Latest is_published is not boolean.')
    # end
    # assert_equal(Feed.count(), feed_service.latest.size, 'latest feeds are not equal to feed channels...')
  end
end
