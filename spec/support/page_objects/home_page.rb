# frozen_string_literal: true

# Selectors and navigation for the public home page (`/`). It deliberately has
# no assertions and no Rails/factory/DB dependency, so the remote staging layer
# (spec/staging) can drive the same object against a real host.
#
# Task 3 already covers the local home-page rendering in
# spec/features/public/home_spec.rb; this object exists for the remote layer's
# "home page returns 200, renders hero content, no console errors" journey.
class HomePage
  HERO_TITLE = '.main_hero__title'
  TRANSCRIPT_TITLES = '.transcript_item__title'
  EMPTY_STATE = '.no-transcripts'

  def visit_path
    page.visit('/')
    self
  end

  def hero_title
    page.find(HERO_TITLE).text
  end

  def transcript_titles
    page.all(TRANSCRIPT_TITLES).map(&:text)
  end

  def empty_state
    page.find(EMPTY_STATE).text
  end

  private

  def page
    Capybara.current_session
  end
end
