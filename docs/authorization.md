# Authorisation

An admin route that changes data is gated twice: a **controller filter** decides whether the caller may reach the action at all, and a **Pundit policy** decides whether they may act on this particular record. This document describes how both layers work on the admin screens, so a new admin controller is protected by construction rather than by imitation of a neighbour that may itself be wrong.

## The three layers

| Layer | Where | What it does |
| --- | --- | --- |
| Session authentication | Devise, plus the `Authentication` concern in `app/controllers/concerns/authentication.rb` | Decides whether there is a signed-in user (`Devise`), and provides the role filters `authenticate_admin!` and `authenticate_moderator!` with the predicates `is_admin?` and `is_moderator?`. `get_current_user` also accepts the `authHeaders` cookie the editor sends. |
| Controller filter | each controller's `before_action`s | Decides whether this caller may use this controller at all. |
| Record policy | `app/policies/*_policy.rb`, called with `authorize` | Decides whether this caller may act on this record. Pundit is included by `AdminController` and `Admin::ProfilesController`, so policies exist for the admin screens only; the public controllers have no policy layer and carry their own checks. |

A route is only protected when one of the last two accepts it. Neither is automatic, and there is no `rescue_from Pundit::NotAuthorizedError`: a refused `authorize` raises, so the caller gets a 500 rather than a sign-in redirect. A filter is what turns a refusal into a redirect.

## Roles

`User#staff?` is `admin? || moderator? || content_editor?` (`app/models/user.rb`). Admin routes generally want staff; some want admin only. Check the route's own controller before assuming; do not infer from the URL.

## The two admin bases, and what each one actually gives you

`AdminController` (`app/controllers/admin_controller.rb`) is the base most `/admin/*` controllers inherit, including the `Admin::Cms::*` ones. It brings `ApplicationController`'s shared `before_action`s, the `admin` layout and `include Pundit`, and it defines `authenticate_staff!` as a **plain method, not a `before_action`**. Inheriting it protects nothing until the controller declares the filter itself:

```ruby
class Admin::Cms::CollectionsController < AdminController
  before_action :authenticate_staff!
```

Treat that line as part of the class definition.

`Admin::ApplicationController` (`app/controllers/admin/application_controller.rb`) inherits `ActionController::Base` directly, so it does **not** get `ApplicationController`'s `before_action`s or Pundit, and it renders the `cms` layout. It does declare `before_action :authenticate_admin!`. **No controller inherits it today**, so it protects nothing by existing: the `Admin::` prefix on a class name says nothing about which base it inherits, and `Admin::Cms::TranscriptsController` sits in that namespace while inheriting `AdminController`.

Several admin controllers carry no filter at all and gate their actions through `authorize` instead — `Admin::CmsController`, `Admin::AppConfigsController`, `Admin::ThemesController`, `Admin::UsersController`, `Admin::InstitutionsController` and `Admin::SiteAlertsController`. That is a per-action gate: an action that forgets its `authorize` is open, and a refusal surfaces as a 500. A filter admits or refuses the whole controller in one place, which is why it is the default below.

Two controllers in the namespace inherit `ApplicationController` rather than `AdminController`, so they have neither its layout nor Pundit unless they ask for them: `Admin::TranscriptsController` declares `before_action :authenticate_admin!`, and `Admin::ProfilesController` includes Pundit itself and checks `current_user.admin?` inside the action that changes the role.

## Adding an admin controller: checklist

1. Choose the base deliberately. Inheriting `AdminController` is the norm; then declare `before_action :authenticate_staff!` (or `:authenticate_admin!`) as the first `before_action`. Switching to `Admin::ApplicationController` changes more than authorisation — it drops the shared `before_action`s and Pundit — so do not adopt it just because it declares a filter.
2. Add `authorize @record` (or `authorize RecordClass`) to every action that reads or changes a specific record, and add the matching predicate to the policy. A filter that admits all staff is not a substitute for a record policy.
3. Check the action's HTTP verb. A GET that changes state (enqueues a job, mutates a session, sends mail) is a bug: it can be triggered by a link, a prefetch, or a crawler.
4. Review the CSRF configuration in `app/controllers/application_controller.rb` before adding a state-changing action; do not assume protection is on.
5. Write the regression spec described below.

## The regression spec

Authorisation bugs are silent: the happy path keeps working. Every controller with a filter gets three cases, as in `spec/features/admin/cms_transcripts_authorisation_spec.rb`:

- an anonymous request is refused **and** the record count is unchanged;
- a signed-in non-staff user is refused the same way;
- staff succeeds (the positive control, so a dead route cannot pass the test).

Use a non-redirect-following driver for the refusal cases so the assertion sees the redirect rather than the page behind it.

## Reviewing a change to an admin controller

- Does the class declare its own filter, or inherit one that actually runs?
- Is every action either filtered or `authorize`d?
- Does any new GET have a side effect?
- Do the regression specs cover anonymous, non-staff and staff?
