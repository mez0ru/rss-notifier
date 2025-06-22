# frozen_string_literal: true

require_relative 'spec_helper'
require 'logger'

describe FeedService do
  it 'Feed service should work' do

    comm = mock()
    comm.expects(:queued).returns([]).at_least_once
    comm.expects(:running).returns([]).at_least_once
    comm.expects(:start).returns(true).at_least_once

    links_array = Feed.select(:link).map(&:link)

    mock_responses = [
      stub(error: nil, body: stub(to_s: File.read("#{__dir__}/feed_httpx_mocks/channel1.xml"))),
      stub(error: nil, body: stub(to_s: File.read("#{__dir__}/feed_httpx_mocks/channel2.xml"))),

      # Error response for error_page
      # stub(error: StandardError.new("Simulated network error"), body: stub(to_s: "")) # Body can be empty or nil on error
    ]

    HTTPX.stubs(:get).with(*links_array).returns(mock_responses.to_enum)

    feed_service = FeedService.new(Logger.new($stdout), comm)
    feed_service.check_all

    # # Now, when you call your code, it will use the mocked HTTPX.get
    # HTTPX.get(*links_array).each.with_index do |res, i|
    #   # Here, 'res' will be one of your 'stub' objects
    #   methodx(res.body.to_s, i)
    # end

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
