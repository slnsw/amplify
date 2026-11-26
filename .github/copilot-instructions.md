# Copilot Instructions — Amplify

## Project Overview

Amplify is a Rails 8.0 transcript correction platform for collaborative editing of machine-generated audio transcripts. Built for the State Library of NSW.

## Tech Stack

- **Ruby** 3.4.13, **Rails** 8.0.2.1
- **PostgreSQL** with pg_search (trigram + full-text)
- **Sidekiq** 7.x on Redis for background jobs
- **Devise** 5.x for authentication (Google/Facebook OAuth + email)
- **Pundit** for authorization (policy objects in `app/policies/`)
- **Draper** for decorators (`app/decorators/`)
- **CarrierWave** + fog-aws for file uploads
- **PaperTrail** for audit logging
- **Bootstrap 4.3** frontend, Gulp-based JS/CSS pipeline
- **Azure Cognitive Services** for speech-to-text

## Key Architectural Patterns

- **Service objects** in `app/services/` for business logic
- **Pundit policies** in `app/policies/` — always use `authorize` in controllers
- **Decorators** via Draper in `app/decorators/` — use for view/presentation logic
- **Background jobs** in `app/jobs/` — Sidekiq-backed, including Azure STT pipeline
- **CarrierWave uploaders** in `app/uploaders/` for audio, images, transcripts
- **Model concerns** in `app/models/concerns/` — `Publishable`, `UidValidation`
- **Data migrations** via `seed_migration` gem in `db/data/`
- **Project configuration** loaded from `project/<id>/project.json` via rake tasks

## Code Conventions

- Use `frozen_string_literal: true` in all Ruby files
- Follow existing RuboCop config (`.rubocop.yml`) — run `bundle exec rubocop`
- Controller actions use Pundit: `authorize @resource` before mutations
- Models use PaperTrail: `has_paper_trail` for auditable models
- Prefer service objects over fat models/controllers
- Use FactoryBot for test data (factories in `spec/factories/`)
- Specs use RSpec with `rails_helper`; Devise helpers in `spec/support/devise.rb`

## Testing

- **Framework:** RSpec 6, FactoryBot, Capybara, Shoulda Matchers
- **Run:** `bundle exec rspec`
- **Coverage:** SimpleCov generates `coverage/index.html`
- Devise test helpers auto-included for controller and feature specs
- Sidekiq runs in test mode (synchronous)
- Azure services are mocked in `spec/support/azures.rb`
- **Controller specs** don't render views by default — add `render_views` inside `describe` when asserting on response body HTML
- **`UserRole` has a unique constraint on `name`** — never call `create(:user)` more than once in a single test without reusing the existing role via `UserRole.find_by(name: 'user') || create(:user_role)`
- **`exec_query` uses positional `$1, $2` placeholders** with `ActiveRecord::Relation::QueryAttribute` typed binds — named `:symbol` placeholders are not supported
- **File path validation** in jobs uses `Pathname.new('/tmp').realpath` (not a hardcoded `/tmp/` string) so it works correctly on macOS where `/tmp` symlinks to `/private/tmp`
- **`SpeechToTextService` raises `RuntimeError`** (not bare `Exception`) — job rescues `StandardError` to avoid swallowing `SignalException`/`NoMemoryError`
- **`to_csv` column order** in `Reports::UserContributions`: headers are `User ID, Name, Edits, Lines, ...` — data rows follow the same order (edit_count before line_count)
- **Jobs should rescue `ActiveRecord::RecordNotFound` before `StandardError`** and re-raise it — if a record is deleted before a job retries, `find` raises `RecordNotFound` and `transcript` is `nil`, so a bare `rescue StandardError` would then raise `NoMethodError` on `transcript.update_columns`
- **Use `fixture_file_upload` instead of `File.open`** for image params in controller specs — `File.open` leaks file descriptors across the test suite
- **Stubbing `Pathname#realpath`**: use `allow_any_instance_of(Pathname).to receive(:realpath).and_wrap_original` and switch on `original.receiver.to_s` to only intercept the specific paths under test — avoid `allow_any_instance_of(...).to receive(:realpath).and_return(...)` which intercepts all Pathnames (including Rails.root) and breaks unrelated code paths
- **Integer ID params from user input**: validate with `/\A\d+\z/` before binding — `.to_i` silently coerces `"abc"` to `0` and `"1 OR 1=1"` to `1`, producing wrong filters; use `param.to_s.match?(/\A\d+\z/)` as the guard and skip the condition on invalid input

## Security

- Run `bundle audit update && bundle audit` for Ruby dependency CVEs
- Run `bundle exec brakeman --no-pager` for static analysis
- Run `npm audit --omit=dev` (requires Node 20+) for JS dependency CVEs
- Brakeman ignore file: `config/brakeman.ignore`
- Bundle audit ignore file: `.bundler-audit.yml`

## Database

- PostgreSQL with extensions: `pg_trgm`, `fuzzystrmatch`
- Schema in `db/schema.rb`; migrations in `db/migrate/`
- Data migrations in `db/data/` — run via `bundle exec rake seed:migrate`
- Key models: `Institution` → `Collection` → `Transcript` → `TranscriptLine` → `TranscriptEdit`

## Deployment

- **Capistrano** to Linux server (Puma + Sidekiq via systemd)
- **AWS CodeBuild** for Docker/ECS deployments
- Post-deploy: `rake project:load`, `rake assets:precompile`, `rake cache:clear`

**`linked_files` is not deployed.** Files named in `config/deploy.rb` (`database.yml`, `application.yml`, `frontend.yml`) come from `shared/` on the server, so changing them in the repository changes nothing until they are removed from the list. `config/initializers/bugsnag.rb` was in that list for years, which is why every repository change to it was inert.

## Error reporting (Bugsnag)

- `config/initializers/bugsnag.rb` ships with the app and reads `BUGSNAG_API_KEY`, falling back to the historical misspelling `BUGSNUG_API_KEY`. `BUGSNAG_RELEASE_STAGE` overrides the stage, which otherwise defaults to `Rails.env` — set it per environment, because a host can run with `RAILS_ENV=production` and be indistinguishable from production.
- The key is never committed. It belongs in Figaro's `config/application.yml` (Capistrano hosts) or the container task definition, and the Sidekiq service needs it as well as Puma.
- The stage must also exist in the project's release-stage list in Bugsnag, or its events will not appear in the project's default view.
- A host without a valid key logs `No valid API key has been set, notifications will not be sent` once and discards every event without raising, so an empty project means the key, not the code.
- To inspect the project from an agent session, use the Data Access API with the configured token: `/user/organizations` (`/organizations` returns 404), then `/organizations/{id}/projects`, then `/projects/{id}/events`. Event JSON names the stage `app.releaseStage`, and filters are encoded as `filters[app.release_stage][][type]=eq&filters[app.release_stage][][value]=staging`. The rate limit is 10 per window, so space the calls out. `spec/initializers/bugsnag_spec.rb` covers the resolution rules.

## Common Commands

```bash
foreman start                              # Start app + Sidekiq
bundle exec rspec                          # Run all tests
bundle exec rubocop                        # Lint
bundle exec brakeman --no-pager            # Security scan
bundle exec rake project:load['project-id'] # Load project config
bundle exec rake cache:clear               # Clear cache
bundle exec rake seed:migrate              # Run data migrations
```

## File Naming

- Controllers: `app/controllers/admin/` for admin, `app/controllers/api/` for API
- Views: ERB templates in `app/views/`
- JS/CSS: Gulp-managed in `gulp/`, compiled to `public/assets/`
- Project content: `project/<project-id>/` with `project.json`, pages, templates

## This Repository Is Public

Everything committed here — code, commit messages, branch names, PR titles and bodies, docs, code comments, test names — is world-readable. Be deliberate:

- Never commit credentials, tokens, keys, customer or staff personal data, or real production/staging hostnames beyond the public site URLs.
- Never publish reproduction steps or impact assessments for an **unfixed** vulnerability. Fixes may be described as fixes ("declare the staff filter"); they must not read as exploit instructions ("anyone can now create…"). See `SECURITY.md`.
- `pull_requests/`, `.superpowers/` and `coverage/` are gitignored and hold internal plans, PR drafts and agent workspaces. Never `git add -A` or `git add .` in this repo; stage explicit paths.
- Do not add a failing or pending spec that demonstrates an unfixed security problem.

## Testing — lessons that cost us time

Read `docs/testing.md` before writing or changing specs. The short version:

- **Anything client-rendered needs `js: true`.** The transcript editor is Backbone served from committed Gulp bundles; a page rendering proves nothing about the editor. The global `after(:each, :js)` hook fails an example when the browser console logs SEVERE — never weaken it, and treat its failure as a real broken bundle.
- **Assert by reloading, not by reading the database.** A spec that queries `TranscriptEdit.last` proves the model works, not the journey.
- **`fill_in` into a `type="date"` — or any field whose handler fires per keystroke — types character by character**, so it emits one AJAX request per character and whichever response lands last wins. Set the value in one operation, or drive a single change event. This produced a 17–22% flake that took a debugging session to explain.
- **Chrome 158 + Capybara 3.39.1** sends `Storage.clearDataForOrigin, origin: '*'`, which Chrome rejects — every `js: true` example then fails *after* passing. `spec/support/capybara_chrome_reset_workaround.rb` rewrites that one call. Do not delete it without re-running the whole suite; see `docs/testing.md` for the removal test.
- **Ruby 3.4.13 + SimpleCov + bootsnap** raise `should not compile with coverage`. `spec/spec_helper.rb` sets `DISABLE_BOOTSNAP_COMPILE_CACHE`. Do not "fix" it by disabling bootsnap entirely. On a branch cut from `develop` before that line existed, run specs with `DISABLE_BOOTSNAP=1`.
- **`.rspec` requires `rails_helper` for every spec file**, including `spec/staging`, so those runs boot Rails and need a local `amplify_test` database.
- **Build test data through `build_content_world`** (`spec/support/features/content_world.rb`), not ad hoc factories. It creates the pages and reference data the views require, including `TranscriptLineStatus` rows the editor dereferences by id.
- **The `:transcript_speaker` factory is broken** (`collection=` does not exist); pass `collection_id:` or create the speaker through the content world.
- **Never `sleep`** and never wrap Selenium calls in `Timeout.timeout`; use the polling helpers in `spec/support/features/waits.rb` (`synchronize`-based).
- **Do not resize the browser inside a spec.** The window size is a driver argument (`LocalChrome::WINDOW_SIZE`) because random ordering leaks it between examples.
- **A Chrome update breaks the first `:js` run.** Selenium Manager keeps one driver per browser major version and its cache lags the browser, so the first run afterwards crashes *inside* the old chromedriver — a native stack trace with no application frames — while the matching driver is fetched. Re-run once. `CHROME_DRIVER_PATH` pins a driver, but only when the file it names is executable, so the value in `.env.example` is a suggestion rather than a requirement. See `docs/testing.md`.
- **Never assume a transcript has no status.** `transcripts.transcript_status_id` defaults to `1`, so a new transcript resolves to whichever status row holds id 1 — and on a fresh CI database that is the spec's own row, which makes the example fail only in CI and only for some orderings. Give the record an explicit status instead. More generally, do not depend on auto-increment ids: CI starts every sequence at 1 and a developer's database does not.

## Verifying a change before claiming it is done

- Run the focused spec, then `bundle exec rspec --tag smoke`, then the full `bundle exec rspec`. Report the counts you actually saw.
- RuboCop: compare against the base commit before claiming "no new offences" — this repo carries pre-existing offences in `app/controllers`, `spec/spec_helper.rb` and a few support files. Check with a base worktree, not by eye.
- The suite is only trustworthy if it fails when the feature is removed. If you add a spec, break the code once and watch it go red.
- **A passing re-run is not proof a flake is fixed.** Reproduce the CI condition instead: `bundle exec rspec --seed <the seed CI printed>`, and where ids are involved reset the sequence (`ALTER SEQUENCE <table>_id_seq RESTART WITH 1`) so the test database looks freshly created.
- **A new spec file reshuffles the random order**, so a latent order dependency can appear in CI while passing locally. When exactly one unrelated example fails, suspect shared state — status rows, sequences, class-level caches — before dismissing it as a flake.

## Staging and deployed-environment checks

- `bin/staging-smoke` drives a deployment with a real browser, GET-only, and writes `tmp/staging_report/report.md` plus screenshots. Use it to produce evidence instead of eyeballing a page.
- Staging and production **share one S3 bucket**; any upload is a production write.
- `GET` is not automatically read-only: some admin GETs enqueue billable jobs. The staging guard fails on non-GET requests and on a deny-list of side-effecting GETs.
- Never point the staging runner at an environment whose credentials you do not own, and never run the authenticated journeys with a shared or personal account that can administer content. The admin journeys take their own dedicated account (`STAGING_ADMIN_EMAIL`), used only for page loads; the read-only guard fails the run on any write.

## Writing prose (docs, PR descriptions, commit bodies)

- **Do not hard-wrap sentences.** Write one paragraph per line and let the reader's client wrap it. A newline in the middle of a sentence shows up as a stray line break in pull-request descriptions and in rendered markdown, and it makes the raw text painful to review and to diff. Wrap only between paragraphs, list items, table rows and code blocks — never between the words of a sentence.
- Keep the same rule for commit bodies. They are read in terminals and on the web.

## CI prerequisites that are easy to forget

- The RSpec workflow must install **ImageMagick** before the suite runs. Every transcript built by the factories attaches a fixture image, and `ImageUploader` validates its dimensions through MiniMagick, so a runner without the `magick` binary fails every example that touches a transcript.
- The workflow must also provide **PostgreSQL** and **Redis** services, generate the untracked `config/database.yml` and `config/application.yml` from their samples, and pin Ruby 3.4.13.
- CodeQL runs on this repository and reviews changed lines. Any `gsub`/`tr` that escapes for a format (markdown tables, HTML, CSV) must escape the escape character first, or the scan reports `rb/incomplete-sanitization` and fails the check.
