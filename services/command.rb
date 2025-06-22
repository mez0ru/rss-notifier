# frozen_string_literal: true

require 'open3'
require 'logger'

class CommandService
  COMMAND_URL_PLACEHOLDER = '%url%'
  attr_accessor :queued
  attr_accessor :running
  attr_accessor :command
  attr_accessor :logger

  def initialize(command, logger)
    @queued = []
    @running = []
    @command = command
    @logger = logger
    @is_running = false
  end

  def running?
    @is_running
  end

  def start
    return unless @queued.size.positive?
    @is_running = true

    @queued.each do |cmd|
      Thread.new do
        @running << cmd
        _, err, status = Open3.capture3(@command.sub(COMMAND_URL_PLACEHOLDER, cmd[:url]))
        if status.success?
          PastUpdate.create(title: cmd[:title], link: cmd[:url], thumbnail: cmd[:thumbnail], published: cmd[:published], feed_id: cmd[:feed_id])
          log('info', "Command \"#{cmd[:url]}\", and saved \"#{cmd[:title]}\" finished.")
        else
          log('error', "Ran command: \"#{cmd[:url]}\" but the returned status was #{status.exitstatus}, error: #{err}")
        end

        @running.delete(cmd)

        @is_running = @running.size.positive?
      end
    end

    @queued = []
  end


  private

  log_levels = {
    "debug" => Logger::DEBUG,
    "info" => Logger::INFO,
    "warn" => Logger::WARN,
    "error" => Logger::ERROR,
    "fatal" => Logger::FATAL
  }

  def log(level, message)
    @logger.send(level, message)
    Log.create(message: message, level: level)
  end
end
