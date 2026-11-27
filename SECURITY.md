# Security policy

This repository is public and the application it describes serves the public. Please report security problems privately — never in an issue, pull request, commit message, or documentation change.

## Reporting a vulnerability

Use GitHub's private vulnerability reporting for this repository (**Security** tab → **Report a vulnerability**). That opens a private advisory visible only to the maintainers.

Please include:

- the affected route, controller or component, and the release or commit you tested;
- what an attacker can do, and what they need first (an account? a session? nothing?);
- the smallest set of steps that reproduces it;
- any evidence (request/response, screenshots) — redact credentials and personal data.

Do not include live credentials, customer data, or details of other people's accounts.

## What to expect

- We aim to acknowledge a report within five business days.
- We will confirm the impact, agree a fix window with the maintainers, and credit you in the advisory if you would like that.
- Please give us the agreed window before publishing anything yourself.

## Scope

In scope: authentication and session handling, authorisation on staff and admin routes, injection (SQL, template, header), unsafe file handling or upload paths, secrets exposure, and any route that changes data without the caller being entitled to.

Third-party dependency advisories are tracked separately (`bundle audit`, `npm audit`, Dependabot) — check whether a finding is already covered before reporting it.

## Handling findings in this repository

- Security fixes are welcome as pull requests **that do not describe the vulnerability in the title, body, commit message or code comments**. Say what you fixed, not how to exploit it, and keep reproduction detail in the private advisory.
- Do not add a failing or pending spec that demonstrates an unfixed vulnerability to a public branch; it publishes the problem along with the code path.
- If a change needs a configuration value (credentials, hostnames, keys), keep the value out of git and document the variable name only.
