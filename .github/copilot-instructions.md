# Copilot Instructions — Amplify

## Project Overview

Amplify is a Rails 8.0 transcript correction platform for collaborative editing of machine-generated audio transcripts. Built for the State Library of NSW.

## Tech Stack

- **Ruby** 3.4.4, **Rails** 8.0.2.1
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
