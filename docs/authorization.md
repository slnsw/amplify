# Authorisation

Every route that changes data must be gated twice: a **controller filter** decides whether the caller may reach the action at all, and a **Pundit policy** decides whether they may act on this particular record. This document describes how that works so a new controller is protected by construction rather than by imitation of a neighbour that may itself be wrong.

## The three layers

| Layer | Where | What it does |
| --- | --- | --- |
| Session authentication | `Authentication` concern, `app/controllers/concerns/authentication.rb` | Decides whether there is a signed-in user, and their role. |
| Controller filter | each controller's `before_action`s | Decides whether this caller may use this controller at all. |
| Record policy | `app/policies/*_policy.rb`, called with `authorize` | Decides whether this caller may act on this record. |

A route is only protected when one of the last two accepts it. Neither is automatic.

## Roles

`User#staff?` is `admin? || moderator? || content_editor?` (`app/models/user.rb`). Admin routes generally want staff; some want admin only. Check the route's own controller before assuming; do not infer from the URL.

## The two admin bases, and the trap in each

`app/controllers/admin/application_controller.rb` (the `Admin::` namespace used by CMS screens) declares `before_action :authenticate_admin!`, so anything under it inherits a filter. That is the safer base.

`app/controllers/admin_controller.rb` (`AdminController`, used by the top-level `/admin/*` controllers and by `Admin::Cms::*`) declares `authenticate_staff!` as a **plain method, not a `before_action`**. Inheriting from it protects nothing until the controller declares the filter itself:

```ruby
class Admin::Cms::CollectionsController < AdminController
  before_action :authenticate_staff!
```

Treat that line as part of the class definition. A controller that inherits `AdminController` without it is open to anyone who can reach the route.

## Adding an admin controller: checklist

1. Choose the base deliberately: `Admin::ApplicationController` when it carries the right filter, otherwise `AdminController` **plus** `before_action :authenticate_staff!` (or `:authenticate_admin!`) as the first `before_action`.
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
