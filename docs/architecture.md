# Architecture

A map of how Amplify fits together, for someone who has to change it without having built it. It describes the wiring rather than every class; the code is the detail.

## In one paragraph

A Rails 8 monolith serving two front ends. Public and staff screens for browsing and administering content are server-rendered ERB. The transcript editor — the product's centre — is a single-page Backbone/Marionette application, built by Gulp into committed bundles under `public/assets/js/`, that renders from JSON endpoints. Content is configured per project from `project/<project-id>/project.json`, loaded by a rake task, and every query is scoped by `ENV['PROJECT_ID']`. Audio and transcripts live on S3 via CarrierWave; long-running work runs on Sidekiq.

## Request lifecycle

1. `config/routes.rb` — note the catch-all at the bottom sending unknown paths to `institutions#index`, which is how institution slugs are routed.
2. `ApplicationController < ActionController::Base` includes `Authentication` (Devise + OmniAuth). Pundit is included by `AdminController` (and `Admin::ProfilesController`), so policies cover the admin screens; authorisation elsewhere is per controller, and per record on the admin screens. See [authorization.md](authorization.md).
3. Views are ERB. Presentation logic belongs in `app/decorators/` (Draper), not in views or models.
4. `Admin::ApplicationController < ActionController::Base` (not the app's `ApplicationController`) declares `authenticate_admin!` and the `cms` layout, but no controller inherits it today — the admin screens inherit `AdminController`. See [authorization.md](authorization.md) before choosing a base.

## The two front ends

**Server-rendered** — home, institution, collection, search, dashboard, all admin screens. Ordinary controller/ERB.

**Client-rendered editor** — `GET /transcripts/:institution/:collection/:id` returns a shell (`<div id="main">`) plus a JSON payload (`show.json.jbuilder`). `gulp/js/` is a Backbone/Marionette app: `router.js` mounts a view into `#main`, views live in `gulp/js/views/`, templates in `gulp/templates/*.ejs`. Editing a line POSTs to `/transcript_edits`; flags to `/flags`; resolution to `/transcript_lines/:id/resolve`.

Consequences that matter:

- **The bundles are committed.** `public/assets/js/*-[hash].js` are build output living in git. Changing anything in `gulp/` requires `npx gulp js` and committing the rebuilt bundles; a deploy does not build them.
- A page can render while the editor is broken. That is why the feature specs run with a real browser and fail on console errors — see [testing.md](testing.md).

## Data model

```
Institution ─┬─ Collection ─── Transcript ─┬─ TranscriptLine ── TranscriptEdit
             │                             ├─ TranscriptSpeaker
             ├─ InstitutionLink            ├─ TranscriptSpeakerEdit
             ├─ TranscriptionConvention    └─ Flag
             └─ Page / PublicPage
```

- `TranscriptLine` carries the machine text plus a best-guess text and a status. `TranscriptLineStatus` is reference data the editor dereferences by id and name; a database without it renders no lines.
- `TranscriptEdit` is one row per user-or-session and line; anonymous contributors are keyed by the Rails session id.
- Consensus rules (`minLinesForConsensus`, `minPercentConsensus`, `maxLineEdits`, `superUserHiearchy`) come from the project file merged with per-institution settings.
- `PaperTrail` records changes on the auditable models.

## Configuration and content

`ENV['PROJECT_ID']` selects a project directory. `Project.getActive` reads `project/<id>/project.json` for menus, consensus thresholds, feature switches and page content; `rake project:load['<id>']` loads it in a deploy. Most queries filter by `project_uid`, so records without it are invisible to the public site.

## Background work

Sidekiq on Redis. Azure speech-to-text, VoiceBase import and SRT processing run as jobs under `app/jobs/`. `Sidekiq::Web` is mounted at `/sidekiq` behind an admin check, and `sidekiq-cron` holds the schedules.

## Files and storage

CarrierWave uploaders in `app/uploaders/`, backed by S3 (`fog-aws`) outside development. **Staging and production share one bucket** (`config/initializers/carrierwave.rb`); treat any upload as a production write.

## Search

`pg_search` with the `pg_trgm` and `fuzzystrmatch` extensions. `TranscriptSearch` and `Collection` scopes do the matching; the editor's autocomplete endpoints are separate.

## Operations

- `GET /health` serves the ALB target-group check (no database, no filters).
- Bugsnag and New Relic receive exceptions and traces.
- Deploys run through Capistrano or the AWS CodeBuild image pipeline; both run `project:load`, `assets:precompile`, `cache:clear` and `sitemap:generate` as post-deploy hooks.

## Where to look first

| You need to change… | Start at |
| --- | --- |
| a public page or listing | `app/controllers/{home,institutions,collections,search}_controller.rb` |
| the editor's behaviour | `gulp/js/views/transcript.js`, `gulp/templates/transcripts/` |
| an admin screen | `app/controllers/admin/**`, `app/views/admin/**` |
| who may do what | [authorization.md](authorization.md) |
| consensus or ingest | `app/models/transcript_line.rb`, `app/services/` |
| project configuration | `project/<id>/project.json`, `lib/tasks/project.rake` |
| tests, or why a page 500s | [testing.md](testing.md) |
