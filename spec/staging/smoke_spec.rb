# frozen_string_literal: true

require_relative 'staging_helper'

# The anonymous, GET-only journeys that produce a deployment's evidence.
#
# Every example drives the deployment named by STAGING_URL through the shared page
# objects (spec/support/page_objects) and asserts on rendered DOM only: no
# database, no factory, no `sign_in_as`. The read-only guard
# (spec/staging/read_only_guard.rb) fails the example if the browser sent a
# request that can change the deployment, and a screenshot of the last page is
# taken for the report.
#
# A deployment that has not picked up the frozen-string fix (commit 6846bace) 500s
# on /search, /collections and /page/*; the link walk below is meant to report
# that, not to tolerate it.
RSpec.feature 'Deployed staging environment', :js, :staging do
  scenario 'serves the home page with its hero content', :aggregate_failures do
    home = HomePage.new.visit_path

    expect(navigation_status).to be_between(200, 399)
    expect(home.hero_title).not_to be_empty
  end

  scenario 'resolves every same-origin navigation and footer link' do
    HomePage.new.visit_path

    expect_links_to_resolve
  end

  scenario 'renders an institution landing page', :aggregate_failures do
    institution = InstitutionPage.new.visit_path(transcript_ref.institution_slug)

    expect(navigation_status).to be_between(200, 399)
    expect(institution.hero_title).not_to be_empty
    # og:title is rendered on nearly every page, so it proves nothing; the
    # institution's own collections and transcripts only render when the slug
    # resolved and its content loaded.
    expect(institution.collection_titles).not_to be_empty
    expect(institution.transcript_titles).not_to be_empty
  end

  scenario 'renders a collection page listing its transcripts', :aggregate_failures do
    ref = transcript_ref
    collection = CollectionPage.new.visit_path(ref.institution_slug, ref.collection.uid)

    expect(navigation_status).to be_between(200, 399)
    expect(collection.transcript_titles).not_to be_empty
  end

  scenario 'returns results for a broad search over the transcript text', :aggregate_failures do
    editor = TranscriptEditorPage.new.visit_transcript(transcript_ref)
    search = SearchPage.new.visit_path(search: broad_search_term(editor.line_texts))

    expect(navigation_status).to be_between(200, 399)
    expect(search.result_titles).not_to be_empty
  end

  scenario 'renders a transcript editor page without editing it', :aggregate_failures do
    editor = TranscriptEditorPage.new.visit_transcript(transcript_ref)

    expect(editor.line_count).to be_positive
    expect(editor.line_texts.join).to match(/\S/)
  end

  scenario 'offers the email form and both OAuth providers on the sign-in page', :aggregate_failures do
    sign_in = SignInPage.new.visit_path

    expect(navigation_status).to be_between(200, 399)
    expect([sign_in.email_field_type, sign_in.password_field_type]).to eq(%w[email password])
    expect(page).to have_link('Sign in with Google', href: SignInPage::GOOGLE_OAUTH_PATH)
    expect(page).to have_link('Sign in with Facebook', href: SignInPage::FACEBOOK_OAUTH_PATH)
  end

  scenario 'serves the compiled template bundle the editor was built against', :aggregate_failures do
    TranscriptEditorPage.new.visit_transcript(transcript_ref)
    scripts = page.all('script[src]', visible: :all).map { |script| script[:src] }
    bundle = scripts.find { |src| src.include?('/js/templates') }

    expect(bundle).not_to be_nil, "the editor page loaded no template bundle (scripts: #{scripts.inspect})"
    expect(bundle).to match(/templates-[0-9a-f]{32}\.js/)
  end
end
