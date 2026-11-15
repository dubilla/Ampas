# Ampas

A Ruby on Rails web application for running award-prediction pools (e.g., Oscars-style). Organizers create pools tied to an award ceremony and its categories/nominees. Participants join a pool, submit an entry by picking nominees per category, and once results are revealed the app scores entries and ranks participants. Entries are hidden from others until the ceremony “locks,” keeping picks private until the event starts.

## Features

- Award ceremonies with lock times to freeze entries before results
- Pools per ceremony; participants submit one entry per pool
- Categories and nominees; winners tracked per nominee
- Scoring and ranking once winners are set
- Authentication with Devise; authorization with Pundit
- Plain CSS (compiled from Bourbon, Neat, and Bitters)
- Propshaft, import maps, and Turbo

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

- Rails 8.1
- PostgreSQL
- Devise, Pundit
- Propshaft, importmap-rails, Turbo
- RSpec

## Requirements

- Ruby 3.4.12, via rbenv (`.ruby-version`)
- PostgreSQL
- Bundler 2.x
- Chrome (for the system specs)

## Getting started

Use the provided setup script:

```bash
bin/setup
```

Manual setup:

```bash
bundle install

# Schema format is :sql, so load structure.sql rather than running migrations.
# In development this also creates and loads the test database.
bundle exec rake db:create db:schema:load db:seed
```

On Apple Silicon, if an Intel Homebrew in `/usr/local` shadows `/opt/homebrew`, native builds fail
or crash at load (`dyld: missing symbol called`). Point them at the arm64 libraries:

```bash
RUBY_CONFIGURE_OPTS="--with-openssl-dir=/opt/homebrew/opt/openssl@3 --with-libyaml-dir=/opt/homebrew/opt/libyaml" \
  rbenv install
bundle config set --local build.pg --with-pg-config=/opt/homebrew/bin/pg_config
```

Run the server:

```bash
bin/dev
```

`bin/dev` also writes server output to `logs/dev.log`. App runs at http://localhost:3000

## Database notes

- Schema is stored as SQL (`config.active_record.schema_format = :sql`), so `db:schema:load` reads from `db/structure.sql`.
- `db/seeds.rb` builds a full ceremony (4 categories, 16 nominees), a pool, and two users:

```
player@example.com   / password   -- has a scored entry
newcomer@example.com / password   -- has no entry
```

  Run it with `bundle exec rake db:seed`. It is idempotent.

## Testing

RSpec, with 106 examples covering models, policies, every route, and the
browser-only Turbo behaviour:

```bash
bundle exec rspec
```

```
spec/models/     award_ceremony, category, entry, pick, pool, user   29
spec/policies/   entry_policy                                        17
spec/requests/   authentication, entries, pools                      57
spec/system/     turbo_navigation (headless Chrome)                   3
```

The system specs need a local Chrome.

## Code quality

- RuboCop: `bundle exec rubocop`

## Configuration and secrets

`secret_key_base` comes from `ENV["SECRET_KEY_BASE"]` in production. Development and test use the
key Rails generates into `tmp/local_secret.txt`, which is gitignored.

## License

MIT — see `LICENSE` for details.
 