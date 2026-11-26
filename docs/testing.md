# Testing Amplify

This document is the map of the test suite: how to run each layer, what each tag means, which spec covers which route, what the suite deliberately cannot prove, and which defects are known rather than fixed. It is the companion to the specs themselves — when this file and the specs disagree, the specs are the truth and this file is the bug.

## Layers

| Layer | Command | What it proves | Cost |
| --- | --- | --- | --- |
| Smoke subset | `bundle exec rspec --tag smoke` | The five journeys that break most often: public home, home page JS health, transcript editor read, email sign-in, admin institutions list. Runs first in every CI run, so a broken core journey fails fast. | ~15s |
| Full suite | `bundle exec rspec` | Every model, service, policy, job, controller, feature and routing example. Runs in CI on every pull request, every push to `develop`/`main`, nightly and on demand. | ~2–3 min |
| Staging run | `STAGING_URL=https://dev.amplify.gov.au bin/staging-smoke` | A *deployed* environment answers its public journeys, read-only, and produces the evidence report. | several minutes plus network |
| One file / example | `bundle exec rspec spec/features/public/search_spec.rb` or `bundle exec rspec path/to_spec.rb:42` | Whatever you are changing. Use this while iterating. | seconds |

The full suite is the gate, and CI runs it on every pull request. The smoke subset runs first in the same job so a broken core journey is reported within a minute rather than at the end of the run; locally it is a quick check while iterating, not a substitute for the full run before a merge.

### Prerequisites

- **Ruby 3.4.13** (`.ruby-version`; `asdf install` then `bundle install`).
- **PostgreSQL** with an `amplify_test` database, reachable with the defaults in `config/database.yml` (`bin/rails db:test:prepare` creates it).
- **Redis** (`redis://localhost:6379` unless `REDIS_URL` says otherwise) for the full suite. `spec/features/routing/fallback_spec.rb` exercises the `/sidekiq` mount, which reads Sidekiq's queues from Redis; without a Redis server those examples fail.
- **Google Chrome**. Selenium Manager (bundled with Selenium 4) downloads/resolves the matching chromedriver automatically; `CHROME_DRIVER_PATH` is not read anywhere.
- **ImageMagick**. `ImageUploader#validate_dimensions` runs every attached image through MiniMagick, so any example that builds a transcript with an image needs the `magick` binary. Without it the factories fail with `MiniMagick::Invalid: You must have ImageMagick or GraphicsMagick installed`. CI installs it with `apt-get install imagemagick`; on macOS use `brew install imagemagick`.
- **Local config files**, created from the tracked samples as in the README (`cp config/database.sample.yml config/database.yml`, and `cp config/application.sample.yml config/application.yml`). Neither is tracked, and `config/application.yml` is not optional: figaro loads it at boot, and CarrierWave/fog raises `Missing required arguments: aws_access_key_id, aws_secret_access_key` without its S3 entries. It also supplies `PROJECT_ID`; CI generates the same file and pins `PROJECT_ID` to `nsw-state-library-amplify` (the project the factories and the tracked `project/` content use).

### Staging runs need a development machine with Postgres

`.rspec` requires `rails_helper` for **every** spec file, so `spec/staging` boots the whole Rails application even though it drives a remote host. `ActiveRecord::Migration.maintain_test_schema!` therefore needs the local `amplify_test` database to exist, exactly as the local suite does. Run the staging runner from a development machine with Postgres available — not from a bare CI container — and do not restructure `.rspec` to avoid that boot: it would change how every other spec loads.

## Tag taxonomy

| Tag | Meaning | Effect when run |
| --- | --- | --- |
| `:smoke` | A representative example from a journey that must never be broken (home, editor read, sign-in, admin institutions). | `bundle exec rspec --tag smoke` — CI's fast first step, before the full suite. |
| `:js` | The example needs a real browser, not rack_test. Uses headless Chrome through Selenium. | Slower; a JS console hook fails the example if Chrome logged any `SEVERE` entry (uncaught exception, `console.error`, failed fetch/XHR). |
| `:staging` | The example drives the deployment named by `STAGING_URL` through the page objects, read-only (see the staging runbook for what the guard does and does not do). | Every example skips with a clear message when `STAGING_URL` is unset; `bin/staging-smoke` refuses a mixed local/remote run. |
| `:requires_credentials` | A `:staging` example that needs `STAGING_EMAIL` and `STAGING_PASSWORD` (a staff account) to sign in. | Skips unless both are set. |
| `:mail` | The example asserts on delivered mail. | Runs the example with ActionMailer's `:test` delivery method and a `default_url_options[:host]`, restoring both afterwards. Needed because `config/initializers/mailer_initializer.rb` forces `:smtp` in every environment, overriding `config/environments/test.rb`. |
| `sidekiq: true` | The example needs Sidekiq jobs to run inline (`Sidekiq::Testing.inline!`). | Wraps the example so `perform_async` executes immediately. On the command line this tag is spelled `--tag sidekiq`. |

RSpec's `:aggregate_failures` appears throughout but is an assertion modifier, not a layer tag.

## Functionality map

Route → what it does → the spec that proves it. "Controller spec" means the behaviour is asserted at the controller level only; a feature spec is a browser-level journey.

### Public content

| Route | What it does | Spec |
| --- | --- | --- |
| `GET /` | Home: hero content, published transcript listing with title and image, empty state. | `spec/features/public/home_spec.rb`, `spec/features/transcripts/transcripts_list_spec.rb` |
| `GET /home` | A second route to the same `HomeController#index`. | The alias path itself is not visited; the action is covered through `GET /` and `spec/controllers/home_controller_spec.rb`. |
| `POST /authenticate` | The client's session handshake (`/authenticate.json`), which the transcript editor requests as it boots. | Controller spec: `spec/controllers/authentication_controller_spec.rb`; sent by every editor journey, but its response is not asserted in a browser. |
| `GET /:institution_slug` | Institution landing (served by the `*path` catch-all → `InstitutionsController#index`): name via `og:title`, hero copy, collections and transcripts, sort by title and by completeness. | `spec/features/public/institution_spec.rb` |
| `GET /:institution_slug/:collection_uid` | Human collection page: its transcript list and the collection-scoped filter label. | `spec/features/public/collection_spec.rb` |
| `GET /collections` | Collection/institution index. HTML and JSON. | `spec/features/public/collection_spec.rb` (browser: the HTML index and its institution selector); `spec/controllers/collections_controller_spec.rb` (both formats) |
| `GET /collections/:id` | JSON only. An HTML request raises `ActionController::UnknownFormat` (406) — the human collection page is `/:institution_slug/:collection_uid`. | `spec/controllers/collections_controller_spec.rb` |
| `POST /collections/list` | Answers `list.js.erb`, which the page's own JS uses to fill `.collect-list` when the institution selector changes. Not JSON. | `spec/features/public/collection_spec.rb` (driven through the real `<select>`) |
| `GET /transcripts` | Transcript index as JSON. | Controller spec only: `spec/controllers/transcripts_controller_spec.rb` |
| `GET /transcripts/:id` | The CMS preview link; redirects to the institution/collection editor route keeping `preview=true`. | `spec/features/transcripts/transcript_preview_spec.rb` |
| `GET /transcripts/:institution/:collection/:id` | The transcript editor shell. Client-rendered: the server ships an empty `#main` and the Backbone view builds it from the `.json` payload. | `spec/features/transcripts/editor_read_spec.rb`, `editor_edit_spec.rb`, `editor_flag_spec.rb`, `transcript_preview_spec.rb`, `spec/features/routing/errors_spec.rb` |
| `GET /transcripts/:institution/:collection/:id.json` | The editor payload: lines, statuses, speakers, edits-only-when-asked. | `spec/features/transcripts/editor_read_spec.rb` (unpublished guard), `spec/features/transcripts/downloads_spec.rb` |
| `POST /transcript_edits` | Persists a line edit (anonymous or signed in), updates rather than duplicates an existing session edit, appears on the dashboard. | `spec/features/transcripts/editor_edit_spec.rb` |
| `GET /transcript_edits`, `GET /transcript_edits/:id` | Edit index/show as JSON. | Controller spec: `spec/controllers/transcript_edits_controller_spec.rb` |
| `POST /transcript_lines/:id/resolve` | Marks a line resolved. | `spec/features/transcripts/editor_edit_spec.rb`, `spec/features/transcripts/editor_flag_spec.rb` |
| `POST /transcript_speaker_edits` | Changes the speaker of a line. | `spec/features/transcripts/editor_edit_spec.rb` |
| `POST /flags` | Flags a line; the line shows as flagged until resolved. | `spec/features/transcripts/editor_flag_spec.rb` |
| `GET /flags`, `GET /flags/:id` | Flag index and show as JSON. | Controller spec: `spec/controllers/flags_controller_spec.rb` |
| `GET /transcript_files/:uid.text` | Plain-text download; `timestamps=1` and `speakers=1` add each line's timing and speaker. | `spec/features/transcripts/downloads_spec.rb` |
| `GET /transcript_files/:uid.vtt` | WebVTT download with cue timings. | `spec/features/transcripts/downloads_spec.rb` |
| `GET /transcript_files/:uid.json` | JSON download: lines, status table, speakers, edits only when requested. | `spec/features/transcripts/downloads_spec.rb` |
| `GET /transcript_files.json` | Lists every transcript, or filters by `updated_after`. | `spec/features/transcripts/downloads_spec.rb` |
| `GET /search` | Reads `search` (not `q`) and deep-searches transcript *line text*; empty state; default title order; `sort_by=completeness` re-ordering (`order` is dropped). | `spec/features/public/search_spec.rb` |
| `GET /page/faq`, `GET /page/about`, `GET /page/:id` | Renders the configured `Page`/`PublicPage` content. | `spec/features/public/static_pages_spec.rb` |
| `GET /page/preview/:id` | Admin preview of a page whose `admin_access` is false. | Controller spec only: `spec/controllers/page_controller_spec.rb` |
| `GET /page/tutorial` | Routed to `page#tutotial` (sic). | Controller spec only: `spec/controllers/page_controller_spec.rb` (`#tutotial`) |

### Authentication and account

| Route | What it does | Spec |
| --- | --- | --- |
| `GET /users/sign_in` | Email/password form plus both OAuth entry points. | `spec/features/auth/sign_in_spec.rb`, `spec/controllers/users/sessions_controller_spec.rb` |
| `POST /users/sign_in` | Accepted credentials land on `/dashboard`; rejected ones stay on the form with the Devise error. | `spec/features/auth/sign_in_spec.rb` |
| `POST /users/auth/google_oauth2`, `POST /users/auth/facebook` | The entry points redirect to the provider (`accounts.google.com` asserted). The provider is never contacted. The authorize routes are POST-only, so the page's GET links fall through to the `*path` catch-all; the spec submits the POST. | `spec/features/auth/sign_in_spec.rb` |
| `GET`/`POST /users/auth/google_oauth2/callback`, `/users/auth/facebook/callback` | Provider callbacks: sign in the user `User.from_omniauth` finds or creates and redirect, or send an unsaveable one to sign-up. | Controller spec only: `spec/controllers/users/omniauth_callbacks_controller_spec.rb` (a browser cannot complete the provider hop — see known gaps) |
| `GET /users/sign_up`, `POST /users` | Registration and the "confirm your email" state; duplicate address refused. Uses the `:mail` hook. | `spec/features/auth/registration_spec.rb` |
| `GET /users/password/new`, `POST /users/password` | Reset email for a real account; nothing sent for an unknown address. Uses the `:mail` hook. | `spec/features/auth/password_reset_spec.rb` |
| `GET /users/password/edit`, `PATCH`/`PUT /users/password` | The emailed reset link's new-password form. | **Not covered**: the reset spec stops at the emailed `reset_password_token`. |
| `GET /users/confirmation/new`, `GET`/`POST /users/confirmation` | Email confirmation and resending its instructions. | **Not covered**: the registration spec stops at the confirmation email. |
| `GET /users/edit`, `PATCH`/`PUT`/`DELETE /users`, `GET /users/cancel` | Devise account edit, update, deletion and sign-up cancel. | **Not covered.** |
| `GET /users/sign_out` (`sign_out_via = :get`) | Sign-out returns to a public page and drops the user-scoped editor state. | `spec/features/auth/sign_out_spec.rb` (`:js`). Deliberately not exercised remotely: the staging guard fails a run that sends it. |
| `GET /dashboard` | The signed-in user's own edits and transcripts, empty state, anonymous redirect to sign-in. | `spec/features/dashboard/contributions_spec.rb` |

### Admin

| Route | What it does | Spec |
| --- | --- | --- |
| `GET /admin` (and `GET /admin/stats`, the same action) | Site statistics counts plus the unresolved-flag moderation queue. | `spec/features/admin/stats_spec.rb`, `spec/features/admin/flags_moderation_spec.rb`, `spec/features/admin/transcript_spec.rb` |
| `GET /admin/stats/:id/institution` | Per-institution edit count rendered into `#edits_for_institution`. | `spec/features/admin/stats_spec.rb` |
| `GET /admin/summary`, `GET /admin/summary/details` | Completion totals, duration, institution filter, and date-range narrowing on `transcripts.updated_at`. | `spec/features/admin/summary_spec.rb` |
| `GET /admin/reports` (+ `/edits`, `/transcripts`, `/users`) | Report index and the contribution table; the users CSV's header order and data-row order. | `spec/features/admin/reports_spec.rb` |
| `GET /admin/analytics` | Frames the Looker Studio report for the signed-in user's institution. | `spec/features/admin/analytics_spec.rb` |
| `GET /admin/profiles`, `PATCH /admin/profiles/:id` | Profile form and the transcribing role. | `spec/features/admin/profiles_spec.rb` |
| `/admin/institutions` (index/new/create/edit/update) | Institution CRUD, including footer links and UID. | `spec/features/admin/institutions_spec.rb` |
| `/admin/institutions/:id/transcription_conventions` | Nested convention CRUD. | `spec/features/admin/institutions_spec.rb`; staff-only authorisation: `spec/features/admin/transcription_conventions_authorisation_spec.rb` |
| `GET /admin/cms` | CMS dashboard (side menu + panes). | Controller spec: `spec/controllers/admin/cms_controller_spec.rb`; remote: `spec/staging/authenticated_spec.rb` |
| `/admin/cms/collections` (new/create/edit/update/destroy) | Collection lifecycle, including an uploaded image. | `spec/features/admin/collections_spec.rb` |
| `/admin/cms/transcripts` (new/create/edit/update/destroy) | Transcript lifecycle. | `spec/features/admin/transcripts_cms_spec.rb`; staff-only authorisation: `spec/features/admin/cms_transcripts_authorisation_spec.rb` |
| `PUT /admin/cms/transcripts/update_multiple` | Bulk publish across the selected `transcript_ids[]`, answered as JavaScript. | `spec/features/admin/transcripts_cms_spec.rb` |
| `POST /admin/cms/transcripts/:id/process_transcript` | Parses an uploaded `.srt` and answers the line rows; the line count changes. | `spec/features/admin/transcripts_cms_spec.rb` |
| `DELETE /admin/cms/transcripts/:id/reset_transcript` | Resets line progress (line rows are restored, not deleted); the summary total drops to 0 %. | `spec/features/admin/transcripts_cms_spec.rb` |
| `GET /admin/cms/transcripts/speaker_search` | Speaker autocomplete for the item form: JSON `suggestions` matching `query`. | `spec/features/admin/transcripts_cms_spec.rb` (the controller spec sends a POST, not this GET) |
| `GET /admin/cms/transcripts/:id/sync` | For an Azure transcript, enqueues `Azure::SpeechToTextJob`, a billable speech-to-text run that rewrites the transcript's lines. | **Not covered.** Staff-only since the authorisation fix; the staging guard fails a run that sends it. |
| `/admin/pages` (index/new/create/edit/update/destroy) | Page CRUD. Its image upload and delete are *not* covered — see known defects. | `spec/features/admin/pages_spec.rb` |
| `/admin/themes` (index/new/create/edit/update/destroy) | Theme CRUD (name only; there is no colour field). | `spec/features/admin/themes_spec.rb` |
| `GET /admin/app_configs/:id/edit`, `PATCH /admin/app_configs/:id` | Site configuration through the CMS side pane. | `spec/features/admin/app_configs_spec.rb` |
| `/admin/site_alerts` (index/new/create/edit/update/destroy) | Alert CRUD and the alert's public surface (`#site-alert--<machine_name>`). | `spec/features/admin/site_alerts_spec.rb` |
| `GET /admin/users`, `PATCH /admin/users/:id` | User list and role promotion (a promoted content editor reaches `/admin/reports`). | `spec/features/admin/users_spec.rb` |
| `DELETE /admin/users/:id` | Deletes a user (answered as JavaScript). | Controller spec only: `spec/controllers/admin/users_controller_spec.rb` |
| `GET /admin/transcripts` | JSON transcript list for the CMS/autocomplete. | Controller spec: `spec/controllers/admin/transcripts_controller_spec.rb` |
| `GET /admin/flags`, `GET /moderator` | Answer **500**: the routes target `Admin::FlagsController`, which does not exist. Moderation is covered through the `/admin` queue instead. | `spec/features/admin/flags_moderation_spec.rb` (queue only) |
| `GET /moderator/flags` | Targets `Moderator::FlagsController`, which does not exist either. | **Not covered.** |

### API, health and routing

| Route | What it does | Spec |
| --- | --- | --- |
| `GET /health` | `Rails::HealthController#show` (AM-278): anonymous 200 with the "up" body the ECS target group checks. | `spec/features/routing/fallback_spec.rb` |
| `GET /sidekiq`, `GET /sidekiq/queues` | Devise + admin-constrained mount: anonymous → sign-in, signed-in non-admin → 404 page, admin → dashboard and queue table. Needs Redis. | `spec/features/routing/fallback_spec.rb` |
| `GET /api/institutions/guids` | Bearer-secret JSON map of institution slug → guid; 401 without the secret. | `spec/features/api/institution_guids_spec.rb`, `spec/controllers/api/institutions/guids_controller_spec.rb` |
| `POST /csp-violation-report-endpoint` | Accepts a browser report posted as `application/csp-report` (a 422 would mean the CSRF skip was lost). | `spec/features/api/csp_reports_spec.rb`, `spec/controllers/api/csp_reports_controller_spec.rb` |
| `GET /v2/edit`, `GET /v2/search` | The temporary v2 pages boot without JS console errors. | `spec/features/routing/javascript_health_spec.rb` |
| `GET /v2/home` | Answers **500** (`@institutions` never assigned). Not covered by design — a spec would enshrine the failure. | — |
| `GET *path` | Falls through to `InstitutionsController#index`: a known slug renders the institution page, an unknown one renders the app's 404 page rather than a server error. A deleted transcript behaves differently for anonymous visitors and editors (see defects). | `spec/features/routing/fallback_spec.rb`, `spec/features/routing/errors_spec.rb` |

## Test infrastructure worth knowing

- **`build_content_world`** (`spec/support/features/content_world.rb`) builds the institution/collection/transcript/page records a journey needs, with keyword options for publishing state, line and speaker counts, extra pages and transcripts. Use it instead of hand-building records; unknown keywords raise.
- **Page objects** (`spec/support/page_objects/`) hold selectors and navigation only — no assertions, no factories — so the local and staging suites share them.
- **`sign_in_as(role)`** (`spec/support/features/authentication_helpers.rb`) authenticates the next request *this process serves*, for local feature specs only. The staging suite signs in through `SignInPage` with real credentials.
- **JS console hook** (`spec/support/features/javascript_errors.rb`) fails any `:js` example whose browser logged a `SEVERE` entry. This is deliberate: a broken bundle can leave the DOM looking correct while the editor is dead. A self-test in `spec/features/routing/javascript_health_spec.rb` runs a throwaway example that logs `console.error` and requires the hook to have failed it, so the hook cannot switch itself off unnoticed. If a driver stops exposing the console log, the run prints a `WARNING: ... JavaScript errors are NOT being checked` line (once per driver) instead of passing silently.
- **Browser window**: the local drivers (`spec/support/capybara.rb`) launch Chrome at 1400×900 (`LocalChrome::WINDOW_SIZE`), wide enough for the desktop-only editor controls, account widget and admin panes. Do not resize the window inside a spec: the suite runs in random order and the size would leak into the next example.
- **Network-log driver**: `LocalChrome::NETWORK_DRIVER` (`driver: :chrome_headless_network`) is the same browser with Chrome's performance log enabled, for examples that must prove a request was *never* sent (`EditorMediaRequests#unaccounted_media_requests` in `spec/support/page_objects/editor_media_requests.rb`).
- **Waiting**: `wait_for_ajax_settle`, `wait_for_editor_boot` and `wait_for_scroll_to_finish` (`spec/support/features/waits.rb`) poll through Capybara's `synchronize`; never wrap Selenium calls in `Timeout.timeout`, which can abort an HTTP call to chromedriver half-way through, and never `sleep`.
- **CDN stub** (`spec/support/feature_cdn_stub.rb`) answers the project content's `s3.amazonaws.com` media requests locally, so a `:js` example does not spend tens of seconds timing out on a CDN this environment cannot reach.
- **Sidekiq** (`spec/support/sidekiqs.rb`) runs jobs inline only for `sidekiq: true` examples; everything else stays in the test queue.
- **Coverage**: SimpleCov writes `coverage/index.html`; the suite's status file is `spec/examples.txt` (used by `--only-failures`).

## The Chrome/Capybara reset workaround

`spec/support/capybara_chrome_reset_workaround.rb` rewrites one Chrome DevTools Protocol call. Capybara 3.39.1 resets each browser session with `Storage.clearDataForOrigin, origin: '*'`; Chrome 158 rejects `'*'` as a URL, so `Capybara.reset_sessions!` raises `InvalidArgumentError` *after* a passing example and the failure is reported against it. The workaround replaces `'*'` with the session's real origin for that one call and changes nothing else.

**When it can be removed:** when Capybara stops sending `Storage.clearDataForOrigin, origin: '*'` (a fixed release), or when Chrome accepts `'*'` again. Remove the file and its `require_relative` in `spec/support/capybara.rb`, then run the full suite; if no `InvalidArgumentError` appears on `:js` examples, the workaround is no longer needed. Do not replace it with a driver swap (e.g. Cuprite) as part of a test change: that rewrites working infrastructure for no coverage gain.

## Ruby 3.4.13 and bootsnap

Ruby 3.4.13 raises `should not compile with coverage` from `InstructionSequence.compile` when bootsnap's iseq cache is used while SimpleCov is active. `spec/spec_helper.rb` sets `ENV['DISABLE_BOOTSNAP_COMPILE_CACHE'] ||= '1'` before SimpleCov loads, which keeps the load-path cache (the main boot win) and skips the iseq/YAML/JSON compile caches. If you ever see that error, export `DISABLE_BOOTSNAP_COMPILE_CACHE=1` in the shell and re-run; it is not an application failure.

## Known gaps — what the suite cannot prove

| Gap | Why | Where it is stubbed / limited |
| --- | --- | --- |
| Azure Speech-to-Text | The suite never calls Azure. Transcript ingestion is stubbed. | `spec/support/azures.rb`, `spec/services/azure/speech_to_text_service_spec.rb`, `spec/jobs/azure/speech_to_text_job_spec.rb` |
| S3 uploads | Test uses CarrierWave's `:file` storage; fog/AWS is never contacted, and the shared production/staging bucket is never written. | `config/initializers/carrierwave.rb`, `spec/support/feature_cdn_stub.rb` |
| OAuth completion | Only the provider redirect is asserted. Automating Google/Facebook violates their terms and breaks on MFA. | `spec/features/auth/sign_in_spec.rb` |
| Email delivery | `config/initializers/mailer_initializer.rb` forces `:smtp` in test, so `ActionMailer::Base.deliveries` never fills without the `:mail` hook; no real SMTP hop is proven. | `spec/support/features/mail_deliveries.rb` |
| `/page/preview/:id` | Only the controller behaviour is covered; there is no browser journey. | `spec/controllers/page_controller_spec.rb` |

Everything else that is broken is listed below as a known defect and is deliberately **not** encoded as a passing expectation.

## Known defects found while writing these specs

These are pre-existing application defects. They are documented so nobody mistakes the suite's silence for health. Each one should become a ticket of its own.

1. **`/admin/flags` and `/moderator` answer 500.** Both routes target `Admin::FlagsController`, which does not exist. The flag queue on `/admin` works and is covered.
2. **Page image upload answers 500.** `Admin::PagesController` authorises `Page` on every action, but `PagePolicy` has no `upload?` predicate.
3. **Page image delete answers 404.** The `delete_upload` route exists but there is no action, and `editor.js` builds a malformed URL for it.
4. **`/v2/home` answers 500.** `V2Controller#home` never assigns the `@institutions` its filter bar reads. `/v2/edit` and `/v2/search` render.
5. **A deleted transcript is inconsistent.** An anonymous visitor gets an empty 200 editor shell (`TranscriptService.find_by_uid` falls back to `Transcript.new`) while a content editor gets the app's 404 page (`find_by_uid_for_admin` returns `nil` and the controller raises `RecordNotFound`). `spec/features/routing/errors_spec.rb` asserts the content editor's 404 page, but for the anonymous visitor it asserts only that the response is not a server error: the empty shell is the defect and is deliberately not asserted as correct.
6. **`GET /api/institutions/guids` does not enforce its token in every configuration.** The spec stubs `LOOKER_STUDIO_EXTERNAL_SECRET` so the 401 path stays covered. The unconfigured case is tracked privately; do not probe a deployed environment to confirm it.
7. **`transcripts.vendor_audio_urls` is double-encoded.** The jsonb default is the *string* `"[]"`, so the reader returns `"[]"` (`Array("[]")` is `["[]"]`, not `[]`) and the editor, seeing a non-empty `vendor_audio_urls`, builds its `<audio>` from the string's characters instead of falling back to `audio_url`. Nothing is fetched only because Chrome cannot play those sources. The no-audio spec in `spec/features/transcripts/editor_read_spec.rb` therefore asserts from Chrome's network log that the editor fetched no media, independently of what the model reports.
8. **The sign-in spam check does not prevent a sign-in.** The check runs after the user has already been authenticated by the framework. The sign-in spec advances the clock past the captcha floor rather than asserting the rejection. Fix tracked privately.

### Authorisation filters restored on two admin controllers

Two admin controllers inherited `AdminController` without applying its `authenticate_staff!` filter. Both now declare it as their first `before_action`, matching `Admin::Cms::CollectionsController`, and each has a regression spec that refuses an anonymous visitor and a signed-in non-staff user (records unchanged) and lets staff through as the positive control:

- `Admin::Cms::TranscriptsController` — `spec/features/admin/cms_transcripts_authorisation_spec.rb`
- `Admin::TranscriptionConventionsController` — `spec/features/admin/transcription_conventions_authorisation_spec.rb`

See [authorization.md](authorization.md) for why the filter must be declared explicitly rather than inherited.

Behaviour that is deliberate and not a defect: `GET /collections/:id` is JSON-only (HTML raises `UnknownFormat`, 406) because the human collection page is `/:institution_slug/:collection_uid`.

## Staging runbook

`bin/staging-smoke` drives a deployed environment with a real browser through read-only page objects and writes the evidence. After every journey a guard (`spec/staging/read_only_guard.rb`) reads Chrome's network log and **detects and fails the run on** any request that can change the deployment:

- any non-GET except the documented sign-in POST, the browser's report-only CSP post and analytics beacons;
- a GET with side effects. GET is *not* read-only in this app: `GET /admin/cms/transcripts/:id/sync` enqueues a paid Azure speech-to-text job that rewrites the transcript's lines, and `GET /users/sign_out` ends the session (`ReadOnlyGuard::SIDE_EFFECT_GET_PATHS`).

The guard is a tripwire, not a barrier: it runs after the journey, so an offending request has already reached the environment by the time it fails the run. What keeps the run read-only is the journeys themselves. Two rules follow:

- **Authenticated staging journeys must never walk links.** A signed-in staff page links to side-effecting GETs (sign-out, CMS sync); visit known pages by path, or click one named link, never `expect_links_to_resolve` while signed in. The anonymous link walk also skips side-effecting paths before visiting them.
- **The staging driver does not ignore certificate errors** (unlike the local driver, which needs to for its self-signed CDN stub): a certificate problem on the environment must fail the run.

1. Run it against Dev:

   ```bash
   STAGING_URL=https://dev.amplify.gov.au bin/staging-smoke
   ```

   It writes `tmp/staging_report/report.md` (journey → result → duration → screenshot, plus failures, every browser console entry and unvisited external links) and one screenshot per journey in `tmp/staging_report/screenshots/`. The directory is deleted at the start of every run so a stale screenshot cannot be attached to a journey that skipped.

2. Attach `tmp/staging_report/report.md` and the screenshots to ticket **146251**.

3. If staging credentials are provided later, re-run with them to include the authenticated journeys (`spec/staging/authenticated_spec.rb`: dashboard, `/admin/summary`, `/admin/reports/users`, `/admin/cms`):

   ```bash
   STAGING_URL=https://dev.amplify.gov.au \
   STAGING_EMAIL='a-staff-account@example.com' STAGING_PASSWORD='…' \
   bin/staging-smoke
   ```

   `STAGING_EMAIL` must be a staff account; without both variables the credentialed examples skip. Each signed-in journey first checks that the sign-in reached a signed-in page and, if it did not, skips with a message naming the account, so wrong credentials read as a skipped run rather than as unrelated failures.

4. Record in the ticket what the run proves and what it does not.

### What the staging suite cannot prove (and therefore still needs SSH)

The run is HTTP/DOM evidence from outside the environment. It cannot establish:

- **Which gem versions are actually loaded.** The run proves what `Gemfile.lock` in this branch says, not what the deployed bundle resolved to. Verify on the host with `bundle list` / `bundle exec ruby -e 'p Gem.loaded_specs["nokogiri"].version'`.
- **Sidekiq/Redis connectivity.** A page can render while the worker is down; verify with `redis-cli ping`, `systemctl status sidekiq` (or the process manager in use) and the Sidekiq dashboard on `/sidekiq` as an admin.
- **Log contents.** Whether requests logged errors, warnings or a stack trace requires reading the application, Sidekiq and web-server logs on the host.
- **Background job processing.** No journey uploads audio or triggers Azure STT/VoiceBase (the suite is read-only and stubbed locally); real job execution can only be observed from the queue and the logs.
- **S3 uploads.** The staging environment shares its bucket with production, so the suite never writes; upload behaviour needs a deliberate, supervised test.
- **OAuth completion and email delivery.** The provider and SMTP hops are outside the environment.
- **Database state and configuration.** Environment variables, `config/application.yml` values and row counts are host-side facts.

That list is the evidence for the access request already made in ticket 146251: each item is something an SSH session proves in minutes and no external browser run can ever prove.

## Continuous integration

`.github/workflows/rspec.yml` runs on GitHub Actions:

| Trigger | Runner | What runs |
| --- | --- | --- |
| `pull_request` | `ubuntu-latest` | `bundle exec rspec --tag smoke`, then `bundle exec rspec` (full suite) |
| `push` to `develop` or `main` | `ubuntu-latest` | the same two steps |
| Nightly `schedule` (16:00 UTC) | `ubuntu-latest` | the same two steps |
| `workflow_dispatch` (Actions tab → RSpec → Run workflow) | `ubuntu-latest` | the same two steps, on the chosen branch |

Every trigger runs the same job: the smoke subset first, then the full suite. A smoke failure fails the job straight away and skips the full run, so the core journeys give the earliest signal; the full suite is still what has to pass.

**Concurrency.** A newer run for the same ref cancels an older one (a force-push to a pull request does not queue a stale run). The nightly run has its own concurrency group and is never cancelled, so a push cannot cancel the nightly run and the nightly run cannot cancel a push's.

**Failure evidence.** When a step fails, the job uploads an artifact named `rspec-failure-<run id>-<attempt>` (kept 14 days) containing `tmp/capybara/` — a screenshot of the page each failed `:js` example left behind, saved by `spec/support/features/failure_screenshots.rb` — plus `log/test.log` and `spec/examples.txt` (the per-example status file `--only-failures` reads).

The job provides:

- **PostgreSQL** as a service container, with `db:test:prepare` loading `db/schema.rb`.
- **Redis** as a service container, because the full suite exercises the `/sidekiq` mount (`spec/features/routing/fallback_spec.rb`); without Redis those examples fail.
- **Ruby 3.4.13** via `ruby/setup-ruby` with bundler caching.
- **Chrome**, preinstalled on `ubuntu-latest`; Selenium Manager resolves the driver, so no manual chromedriver step is needed.
- **`config/database.yml` and `config/application.yml`**, generated from the tracked `*.sample.yml` files because both are gitignored. figaro needs `config/application.yml` at boot — CarrierWave/fog raises `Missing required arguments: aws_access_key_id, aws_secret_access_key` without it — and the workflow pins `PROJECT_ID` to `nsw-state-library-amplify`, the project the factories and the tracked `project/` content use.
- `RAILS_ENV=test`, `REDIS_URL` and `DISABLE_BOOTSNAP_COMPILE_CACHE`.

Two operational notes:

- The repository's default branch is **`develop`**, not `main`. The full suite runs on every pull request and every push there; `main` is included so a release branch is covered too.
- **AWS CodeBuild deployments do not run the tests.** The Docker/ECS pipeline builds and deploys; the GitHub Actions workflow above is the only automated gate. A merge that breaks the suite is caught here, not by the deploy.
