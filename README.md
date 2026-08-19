# Ampas

A Ruby on Rails web application for running award-prediction pools (e.g., Oscars-style). Organizers create pools tied to an award ceremony and its categories/nominees. Participants join a pool, submit an entry by picking nominees per category, and once results are revealed the app scores entries and ranks participants. Entries are hidden from others until the ceremony “locks,” keeping picks private until the event starts.

> **This app is mid-upgrade.** It currently runs Rails 7.1.5.1 on Ruby 3.3.11 and is being moved to
> Rails 8 / Ruby 3.3, one phase at a time. See [docs/rails-upgrade-plan.md](docs/rails-upgrade-plan.md)
> for the ladder, the known blockers, and the latent bugs found along the way.

## Features

- Award ceremonies with lock times to freeze entries before results
- Pools per ceremony; participants submit one entry per pool
- Categories and nominees; winners tracked per nominee
- Scoring and ranking once winners are set
- Authentication with Devise; authorization with Pundit
- Clean, responsive UI via Bourbon, Neat, and Bitters
- Asset Pipeline with Sprockets, jQuery, and Turbolinks

## Architecture overview

- Models
  - `AwardCeremony`: has many `Category`, has many `Pool`; fields include `name`, `locks_at`
  - `Category`: belongs to `AwardCeremony`, has many `Nominee`; exposes `winner`
  - `Nominee`: belongs to `Category`; boolean `winner`
  - `Pool`: belongs to `AwardCeremony`, has many `Entry`; delegates ceremony info; `locked?` based on `locks_at`
  - `Entry`: belongs to `Pool` and `User`, has many `Pick`; `score` counts correct picks after winners are set
  - `Pick`: belongs to `Entry`, `Category`, `Nominee`; validates nominee presence
  - `User`: Devise user; has many `Entry`, has many `Pool` through entries
- Controllers & routes
  - Root `home#index` (redirects to `pools#index` when signed in and enrolled)
  - `award_ceremonies#index` list
  - `pools#index|show`; join via `entries#new` when not yet joined
  - `entries#new|create|edit|update|show` with Pundit policies to hide/show and prevent edits after lock
- Views
  - Pool leaderboard shows scores and links to entries (visible only when allowed)
  - Entry pages show picks; winners column appears only after lock

## Tech stack

- Rails 7.1.5.1
- PostgreSQL
- Devise, Pundit
- Sprockets, jQuery, Turbolinks
- Bourbon/Neat/Bitters (SCSS)
- Tests: Rails default Minitest (RSpec is present in Gemfile but not configured)

## Requirements

- Ruby 3.3.11, via rbenv (`.ruby-version`)
- PostgreSQL
- Bundler 2.x
- Node.js (for assets)

## Getting started

Use the provided setup script:

```bash
bin/setup
```

Manual setup:

```bash
bundle install

# Schema format is :sql, so load structure.sql rather than running migrations.
bundle exec rake db:create db:structure:load db:seed
RAILS_ENV=test bundle exec rake db:create db:structure:load
```

Run the server:

```bash
bin/rails server
```

App runs at http://localhost:3000

## Database notes

- Schema is stored as SQL (`config.active_record.schema_format = :sql`), so `db:schema:load`/`db:setup` read from `db/structure.sql`.
- `db/seeds.rb` builds a full ceremony (4 categories, 16 nominees), a pool, and two users:

```
player@example.com   / password   -- has a scored entry
newcomer@example.com / password   -- has no entry
```

  Run it with `bundle exec rake db:seed`. It is idempotent.

## Testing

RSpec, with 59 examples covering models, policies, and every route:

```bash
bundle exec rspec
```

```
spec/models/     entry, pool, category, pick     22
spec/policies/   entry_policy                     9
spec/requests/   authentication, pools, entries  28
```

These are **characterization tests** -- they assert what the app does today, bugs
included, so the Rails upgrade can be verified as behavior-preserving. Four latent
bugs are recorded as passing specs marked `TODO(post-upgrade)` rather than fixed;
the most serious is that `EntriesController#update` performs no authorization at
all. See the upgrade plan for the full list.

Specs are request specs rather than controller specs, and avoid `assigns`, so they
keep working from Rails 5 onward without `rails-controller-testing`.

The `test/` directory is stock Rails scaffolding and contains no tests.

## Code quality

- RuboCop: `bundle exec rubocop`
- Rails Best Practices: `bundle exec rails_best_practices .`

## Configuration and secrets

`secret_key_base` comes from `ENV["SECRET_KEY_BASE"]` in production. Development and test use the
key Rails generates into `tmp/local_secret.txt`, which is gitignored. There is no `config/secrets.yml`
-- `Rails.application.secrets` was removed in Rails 7.2.


- Development and test secrets are in `config/secrets.yml`.
- Production expects `SECRET_KEY_BASE` in the environment.

## License

MIT — see `LICENSE` for details.
 