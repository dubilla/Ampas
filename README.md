# Ampas

A Ruby on Rails web application for running award-prediction pools (e.g., Oscars-style). Organizers create pools tied to an award ceremony and its categories/nominees. Participants join a pool, submit an entry by picking nominees per category, and once results are revealed the app scores entries and ranks participants. Entries are hidden from others until the ceremony “locks,” keeping picks private until the event starts.

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

- Rails 4.2.8
- PostgreSQL
- Devise, Pundit
- Sprockets, jQuery, Turbolinks
- Bourbon/Neat/Bitters (SCSS)
- Tests: Rails default Minitest (RSpec is present in Gemfile but not configured)

## Requirements

- Ruby 2.2.2 or higher
- PostgreSQL
- Bundler
- Node.js (for assets)

## Getting started

Use the provided setup script:

```bash
bin/setup
```

Manual setup:

```bash
bundle install
bin/rails db:create db:migrate
```

Run the server:

```bash
bin/rails server
```

App runs at http://localhost:3000

## Database notes

- Schema is stored as SQL (`config.active_record.schema_format = :sql`), so `db:schema:load`/`db:setup` read from `db/structure.sql`.
- Seeds are currently empty. You can create sample data in the Rails console:

```ruby
ac = AwardCeremony.create!(name: "Oscars 2025", locks_at: 1.week.from_now)
cat = ac.categories.create!(name: "Best Picture")
nom_a = cat.nominees.create!(name: "Movie A")
nom_b = cat.nominees.create!(name: "Movie B")
pool = ac.pools.create!
user = User.create!(email: "test@example.com", password: "password123")
entry = pool.entries.create!(user: user, picks_attributes: [ { category_id: cat.id, nominee_id: nom_a.id } ])
# Later, set winner:
nom_a.update!(winner: true)
```

## Testing

The repository currently uses Rails’ default test framework (Minitest):

```bash
bin/rake test
```

RSpec is included in the Gemfile but not initialized; if you prefer RSpec, run its installer and migrate tests accordingly.

## Code quality

- RuboCop: `bundle exec rubocop`
- Rails Best Practices: `bundle exec rails_best_practices .`

## Configuration and secrets

- Development and test secrets are in `config/secrets.yml`.
- Production expects `SECRET_KEY_BASE` in the environment.

## License

MIT — see `LICENSE` for details.
 