# frozen_string_literal: true

# Reads the text of every node matching a selector as one re-tryable read.
#
# The read is several WebDriver calls (`all`, then `text` per row), so the page
# can replace the rows between them. `DetachedNodeRetry` reruns a command whose
# document disappeared and raising `ElementNotFound` reruns the block when a row
# goes away, so `synchronize` re-queries until the document stops changing
# instead of returning rows from two different renders.
module ListTexts
  # `within` scopes the read to one part of the page, so a grouping bug cannot be
  # hidden by rows that belong to another group.
  def texts_for(selector, within: page.document)
    within.synchronize { within.all(selector).map(&:text) }
  end
end

RSpec.configure do |config|
  config.include ListTexts
end
