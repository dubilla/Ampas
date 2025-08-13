# TODO

## Modernization and maintenance
- Upgrade Rails to 6.1/7.x and Ruby to a currently supported version.
- Update gems (Devise, Pundit, Bourbon/Neat, etc.) and remove deprecated ones (e.g., CoffeeScript if introduced later).
- Replace jQuery/Turbolinks with Hotwire (Turbo + Stimulus) or a modern frontend approach.
- Consider using import maps or a modern bundler instead of legacy Sprockets where appropriate.
- Add Dockerfile and docker-compose for easy local setup.
- Add CI (GitHub Actions) for tests, linting, and security checks (bundler-audit, brakeman).

## Data integrity and validations
- Add presence validations where missing (e.g., `Pool.award_ceremony`, `Category.award_ceremony`, `Entry.pool`, `Entry.user`).
- Enforce one entry per user per pool at the DB and model levels:
  - Model validation `validates :user_id, uniqueness: { scope: :pool_id }`.
  - DB unique index on `entries (user_id, pool_id)`.
- Enforce one pick per category per entry:
  - Model validation `validates :category_id, uniqueness: { scope: :entry_id }` on `Pick`.
  - DB unique index on `picks (entry_id, category_id)`.
- Add NOT NULL constraints for foreign keys and critical columns across tables.
- Add `dependent: :destroy` where appropriate to keep data consistent (e.g., `Pool has_many :entries` and cascading picks).

## Authorization and security
- Extend Pundit policies to cover `create`/`new` and pool membership rules (e.g., invite-only pools).
- Ensure entries cannot be created/edited after `locks_at` at both the model and controller levels.
- Add CSRF-safe JSON endpoints if APIs are introduced.
- Rate limit sensitive endpoints (e.g., logins) via rack-attack.
- Move development/test secrets out of VCS and use `dotenv-rails` for local configuration.

## Product and UX enhancements
- Implement pool creation and invitation flows (invite code or email invites).
- Add an admin UI to manage ceremonies, categories, nominees, and mark winners.
- Improve leaderboard UX: highlight correct picks, show deltas, and tie-breakers.
- Allow users to view their own entries pre-lock, but keep others’ entries private until lock (already enforced; expand to pools index views).
- Add pagination or virtualization for large pools; improve accessibility and mobile layout.
- Provide public/shareable pool pages with obfuscated IDs or slugs.

## Performance and reliability
- Eager-load associations in leaderboard views (e.g., `@pool.entries.includes(picks: [:nominee, :category])`).
- Add indexes for common queries (most exist; add composites suggested above).
- Background jobs for heavy tasks if/when added (e.g., emailing results).

## Testing and quality
- Add model and policy tests for locking, scoring, and visibility rules.
- Add controller/request specs for entries and pools.
- Decide on Minitest vs. RSpec; remove the unused framework to reduce confusion.
- Enforce linting in CI; add pre-commit hooks.

## Developer experience
- Expand `bin/setup` to provision DB users, run linters/tests, and seed demo data.
- Provide sample seeds for a full ceremony to demo the app quickly.
- Write a short contribution guide (coding style, PR checks, branching model).