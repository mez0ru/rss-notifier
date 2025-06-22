# frozen_string_literal: true


FeedInfo = Struct.new('Feed', :thumbnail, :url, :name, :title, :published, :is_published, :feed_id)

class FeedService
  attr_accessor :queued, :latest, :last_checked_on, :duration, :thread, :logger, :command_service

  def initialize(logger, command_service, duration = 60 * 15)
    @queued = []
    @latest = []
    @last_checked_on = nil
    @logger = logger
    @duration = duration
    @command_service = command_service
    Thread.abort_on_exception = true

    # start_timer
  end

  def check_all
    all_feeds = Feed.all
    conds = Condition.all
    HTTPX.get(*all_feeds.map(&:link)).each.with_index do |res, i|
      next if res.error

      check_rss_content res.body.to_s, conds, all_feeds[i]
    end
    @last_checked_on = Time.new

    puts 'RSS Checked successfully!'
  end

  def start_timer
    @thread ||= Thread.new do
      loop do
        check_all
        sleep @duration
      end
    end
  end

  private

  def log(level, message)
    @logger.send(level, message)
    Log.create(message: message, level: level)
  end

  def check_rss_content(xml_body, conditions, feed)
    doc = Nokolexbor::HTML(xml_body)

    # check if unmodified
    crc32 = Zlib.crc32(doc.at_xpath('//entry/*/*[name()=\'media:content\']/@url')&.text)
    return if feed[:crc32] == crc32

    feed.update(crc32: crc32)
    entries = doc.xpath('//entry')
    entries.each do |node|
      title = node.at_xpath('.//*[name()=\'media:title\']')&.text
      desc = node.at_xpath('.//*[name()=\'media:description\']')&.text
      url = node.at_xpath('.//*[name()=\'media:content\']/@url')&.text

      if entries.first == node
        @latest << FeedInfo.new(
          thumbnail: node.at_xpath('.//*[name()=\'media:thumbnail\']/@url')&.text,
          url: url,
          name: feed.name,
          title: title,
          published: node.at_xpath('./published')&.text,
          is_published: node.at_xpath('.//*[name()=\'media:statistics\']/@views')&.text.to_i&.positive? || false,
          feed_id: feed.id
        )
      end
      conditions.each do |c|
        next unless feed.link.include? c[:url]

        cc = Regexp.new(c[:regex], Regexp::IGNORECASE)
        next unless cc.match?(title) || cc.match?(desc)

        next if PastUpdate.include?(link: url)

        @queued << FeedInfo.new(
          thumbnail: node.at_xpath('.//*[name()=\'media:thumbnail\']/@url')&.text,
          url: url,
          name: feed.name,
          title: title,
          published: node.at_xpath('./published')&.text,
          is_published: node.at_xpath('.//*[name()=\'media:statistics\']/@views')&.text.to_i&.positive? || false,
          feed_id: feed.id
        )

        log('info', "Added to queue \"#{url}\".")
      end
    end

    @command_service.queued.concat(@queued - @command_service.running)
    @command_service.start
  end
end
