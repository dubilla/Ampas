# TODO

## Modernization and maintenance
- Upgrade to Rails 8.1 and Ruby 3.4.
- Update gems (Devise, Pundit, Bourbon/Neat, etc.) and remove deprecated ones (e.g., CoffeeScript if introduced later).
- Add linting and security checks (bundler-audit, brakeman) to CI.

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
- Fix `Entry#destroy`, which currently raises `ActiveRecord::InvalidForeignKey`: `validates_associated :picks` caches the association during create, so `dependent: :destroy` walks a stale empty array. Latent only because nothing destroys an entry. Covered by a characterization spec.
- Validate that a `Pick`'s nominee belongs to the pick's own category — nothing enforces this today.

## Authorization and security
- **Add `authorize` to `EntriesController#update`.** It performs no authorization at all, unlike `#show` and `#edit`, so any authenticated user can rewrite any other user's picks — including after lock. Highest-priority item in this file; covered by a characterization spec that currently asserts the broken behavior.
- Add the nil guard to `EntryPolicy#edit?` that `#show?` already has; it raises `NoMethodError` for a signed-out visitor.
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
- Delete the empty `test/` scaffolding.
- Enforce linting in CI; add pre-commit hooks.

## Developer experience
- Expand `bin/setup` to provision DB users, run linters/tests, and seed demo data.
- Write a short contribution guide (coding style, PR checks, branching model).