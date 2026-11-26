# frozen_string_literal: true

# Reads the text of every node matching a selector, retrying when the page
# replaces the rows underneath the read.
#
# `Capybara::Node::Element#text` is a single WebDriver call outside Capybara's
# synchronize loop, so a row that is re-rendered between the `all` query and the
# text call makes chromedriver answer "Node with given id does not belong to the
# document". Selenium surfaces that as an UnknownError, which Capybara does not
# retry, so the example fails on a page that is merely still settling — after
# `page.refresh`, for instance. Raising ElementNotFound instead puts the read
# inside `synchronize`, which re-queries until the document stops changing.
module ListTexts
  STALE_NODE = 'Node with given id does not belong to the document'

  def texts_for(selector)
    page.document.synchronize do
      page.all(selector).map(&:text)
    rescue Selenium::WebDriver::Error::WebDriverError => e
      raise Capybara::ElementNotFound, e.message if e.message.include?(STALE_NODE)

      raise
    end
  end
end

RSpec.configure do |config|
  config.include ListTexts
end
