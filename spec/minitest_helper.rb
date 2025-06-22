# frozen_string_literal: true
ENV['MT_NO_PLUGINS'] = '1' # Work around stupid autoloading of plugins
gem 'minitest'
gem 'mocha'
require 'minitest/global_expectations/autorun'
require 'minitest/hooks/default'
require 'minitest/autorun'
require 'mocha/minitest'

require 'httpx'
require 'nokolexbor'
require 'zlib'
# Dir['../services/*.rb'].each{|f| puts f.inspect}
require_relative '../services/feed'
require_relative '../services/command'


class Minitest::HooksSpec
  around(:all) do |&block|
    DB.transaction(rollback: :always){super(&block)}
  end

  around do |&block|
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true){super(&block)}
  end

  def log
    LOGGER.level = Logger::INFO
    yield
  ensure
    LOGGER.level = Logger::FATAL
  end
end


freeze_core = false # change to true to enable refrigerator
if freeze_core
  at_exit do
    require 'refrigerator'
    Refrigerator.freeze_core
  end
end
