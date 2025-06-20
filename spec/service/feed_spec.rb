# frozen_string_literal: true

require_relative 'spec_helper'
require 'logger'

describe FeedService do
  it 'Feed service should work' do
    feed_service = FeedService.new logger: Logger.new($stdout)
    feed_service.check_all
    refute_nil(feed_service.queued, 'Queued feeds are nil...')
    refute_empty(feed_service.queued, 'There should be queued feeds, but there\'s none...')

    feed_service.queued.each do |feed|
      refute_nil(feed[:name], 'Queued name is nil.')
      refute_empty(feed[:name], 'Queued name is empty.')
      refute_nil(feed[:thumbnail], 'Queued thumbnail is nil.')
      refute_empty(feed[:thumbnail], 'Queued thumbnail is empty.')
      refute_nil(feed[:url], 'Queued url is nil.')
      refute_empty(feed[:url], 'Queued url is empty.')
      refute_nil(feed[:title], 'Queued title is nil.')
      refute_empty(feed[:title], 'Queued title is empty.')
      refute_nil(feed[:published], 'Queued published is nil.')
      refute_empty(feed[:published], 'Queued published is empty.')
      refute_nil(feed[:is_published], 'Queued is_published is nil.')
      assert_includes([true, false], feed[:is_published], 'Queued is_published is not boolean.')
      refute_nil(feed[:feed_id], 'Queued feed_id is nil.')
      assert_instance_of(Integer, feed[:feed_id], 'Queued feed_id is not an integer.')
    end

    refute_nil(feed_service.latest, 'Latest feeds are nil...')
    refute_empty(feed_service.latest, 'There should be latest feeds, but there\'s none...')
    feed_service.latest.each do |feed|
      refute_nil(feed[:name], 'Latest name is nil.')
      refute_empty(feed[:name], 'Latest name is empty.')
      refute_nil(feed[:thumbnail], 'Latest thumbnail is nil.')
      refute_empty(feed[:thumbnail], 'Latest thumbnail is empty.')
      refute_nil(feed[:url], 'Latest url is nil.')
      refute_empty(feed[:url], 'Latest url is empty.')
      refute_nil(feed[:title], 'Latest title is nil.')
      refute_empty(feed[:title], 'Latest title is empty.')
      refute_nil(feed[:published], 'Latest published is nil.')
      refute_empty(feed[:published], 'Latest published is empty.')
      refute_nil(feed[:is_published], 'Latest is_published is nil.')
      assert_includes([true, false], feed[:is_published], 'Latest is_published is not boolean.')
      refute_nil(feed[:feed_id], 'Latest feed_id is nil.')
      assert_instance_of(Integer, feed[:feed_id], 'Latest feed_id is not an integer.')
    end
    assert_equal(Feed.count(), feed_service.latest.size, 'latest feeds are not equal to feed channels...')
  end
end
