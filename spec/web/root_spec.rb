# frozen_string_literal: true

require_relative 'spec_helper'

describe '/' do
  it "should " do
    visit '/'
    # Test that it has a card
    # page.has_selector?('article').must_equal true

    # Test that it has the right content
    # page.has_content?('moona').must_equal true

    page.title.must_equal 'RSS Notifier'
    # ...
  end
end
