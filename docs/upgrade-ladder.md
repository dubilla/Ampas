# Ampas: Upgrade Ladder (Rails 7.1 → 8.1, Ruby 3.3 → 3.4)

**Status:** Step 2 in review; step 3 next. Rails 7.1.5.1 on Ruby 3.3.13.
**Goal:** Rails 8.1 on Ruby 3.4, deployed to Heroku, with the open Dependabot alerts closed.
**Supersedes:** Phase 5 of [`rails-upgrade-plan.md`](rails-upgrade-plan.md). Phases 0–4 there remain the history.

Work this one step at a time. Each step is one PR. **Do not start a step until the previous one is
verified and merged.**

---

## Why this ladder

Heroku sets no hard floor on Rails or Ruby, but it only supports versions that Rails Core and Ruby
Core still patch. As of 2026-11-13:

| | Oldest patched | Notes |
|---|---|---|
| Rails | **8.1** | 8.0 lost security support 2026-11-07; 7.2 on 2026-08-09; 7.1 on 2025-10-01 |
| Ruby | 3.3 (until 2027-03-31) | **3.4** is patched until 2028-03-31; Rails 8.1 needs Ruby >= 3.2 |

Rails 7.1 receives no patches, so about 30 Dependabot alerts cannot be fixed on it. The worst is
[#162](https://github.com/dubilla/Ampas/security/dependabot/162) (critical, CVE-2026-66066, Active
Storage + libvips arbitrary file read). Most of the Rails alerts list 8.0.5.2 or later as the first
patched version.

**Rule:** change one axis (Ruby *or* Rails) per step, and only to a pair that is officially
supported. That way every step ends in a known-compatible, deployable combination, and we never test
an unsupported pair like Rails 7.1 + Ruby 3.4.

## The steps

| Step | Change | End state | Why the pair is safe |
|---|---|---|---|
| 0 | (today) | Rails 7.1 + Ruby 3.3.11 | CI green |
| 1 | Production checks in CI | same | no version change |
| 2 | Ruby 3.3.11 → 3.3.13, app runs locally | Rails 7.1 + Ruby 3.3.13 | patch bump; Heroku's recommended 3.3 |
| 3 | Remove Active Storage and other unused frameworks | same | no version change; closes #162 |
| 4 | Rails 7.1 → 7.2 | 7.2 + 3.3 | 7.2 supports Ruby >= 3.1 |
| 5 | Rails 7.2 → 8.0 | 8.0 + 3.3 | 8.0 supports Ruby >= 3.2 |
| 6 | Ruby 3.3 → 3.4 | 8.0 + 3.4 | 8.0 shipped alongside 3.4 |
| 7 | Rails 8.0 → 8.1 | 8.1 + 3.4 | the target |
| 8 | Deploy to Heroku | | |

---

## Verifying every step

A step is done when all of these pass:

1. **CI is green.** Specs, plus the production checks from step 1 once that lands.
2. **Production checks locally**, if CI doesn't run them yet:
   ```bash
   bundle exec rails zeitwerk:check
   RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails runner 'puts "ok"'
   RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile
   ```
   These run because a green suite has hidden production-only failures three times already: the
   Sprockets 4 manifest, the `storage.yml` boot failure, and Uglifier choking on ES6. Test mode
   doesn't eager-load code or compile assets.
3. **Local smoke test** (from step 2 on). Boot the server, sign in as `player@example.com` /
   `password`, open a pool, view and edit an entry, then log out. Logout uses jQuery UJS
   `method: :delete`, which no spec exercises because there are no JS/browser tests.
4. **Reviewer pass** on the diff before committing (the `reviewer` subagent).
5. Merge, then add a dated line to the progress log below.

---

## Step 1: Production checks in CI

Add three steps to `.github/workflows/ci.yml` after "Run specs": `zeitwerk:check`, a
`RAILS_ENV=production` eager-load boot, and `assets:precompile`. Give the production steps
`SECRET_KEY_BASE: dummy`. Production's database (`ampas`) doesn't exist in CI. Eager loading
shouldn't touch the database, but if a step tries to connect, set `DATABASE_URL` to the service
container's test database for that step.

**Verify:** CI is green on the PR. Optional: sanity-check that the boot step fails by temporarily
deleting `app/assets/config/manifest.js` on a scratch commit.

## Step 2: Ruby 3.3.13 and a working local app

The local Ruby toolchain is broken. Fixing it is the real work of this step.

- **Two Homebrews.** `brew`, `pkg-config` and `pg_config` all resolve to an Intel Homebrew in
  `/usr/local` first, so native builds find x86_64 libraries while building arm64 code. The linker
  skips them with a warning, and the result fails to build or crashes at load with
  `dyld: missing symbol called` (this hit the `psych` 5.4.0 gem). The arm64 Homebrew at
  `/opt/homebrew` has everything needed. Put `/opt/homebrew/bin` first on `PATH` for builds, and
  pass its paths explicitly:
  ```bash
  RUBY_CONFIGURE_OPTS="--with-openssl-dir=/opt/homebrew/opt/openssl@3 --with-libyaml-dir=/opt/homebrew/opt/libyaml" \
    rbenv install 3.3.13
  bundle config set --local build.pg --with-pg-config=/opt/homebrew/bin/pg_config
  ```
- **rvm shadows rbenv.** `~/.profile` and `~/.bash_profile` source rvm, which exports
  `GEM_HOME`/`GEM_PATH` pointing at rvm's 3.3.4 gems and puts its rubies on `PATH`. rbenv's shims
  come first on `PATH`, so once 3.3.13 is installed `ruby` resolves correctly, but the rvm gem
  variables still leak in. Until rvm is removed, unset `GEM_HOME GEM_PATH MY_RUBY_HOME RUBY_VERSION`
  in the shell before running Bundler.
- Bump `.ruby-version`, the `ruby` line in `Gemfile`, and `ruby-version` in `ci.yml` to 3.3.13. Run
  `bundle update --ruby`. Only the `RUBY VERSION` line of `Gemfile.lock` changes.
- Create the databases. In development, `db:create db:schema:load` also creates and loads the test
  database, so a separate `RAILS_ENV=test` load fails with "relation already exists":
  ```bash
  bundle exec rake db:create db:schema:load db:seed
  ```
- Dev logging: `bin/dev` runs `bin/rails server` with its output mirrored to `logs/dev.log`, which is
  truncated on each start. `/logs` was already gitignored. Documented in the README.

**Verify:** specs pass locally, the production checks pass, the smoke test passes, CI is green.

## Step 3: Remove Active Storage and other unused frameworks

The app never uses Active Storage. Evidence: no `has_one_attached` / `has_many_attached`, no
`file_field`, no `active_storage_*` tables in `db/structure.sql`, and no `ruby-vips` /
`image_processing` / `mini_magick` gem. Active Storage is only loaded because
`require 'rails/all'` loads every framework, and the `rails` meta-gem puts it in the lockfile.

**Prepared work** lives in a git stash (`git stash list`: *"step 3 WIP: remove Active Storage…
(unverified)"*), made on branch `remove-unused-rails-frameworks`. It:

- replaces `require 'rails/all'` with individual railties: active_model, active_job, active_record,
  action_controller, action_mailer (Devise mail), action_view, sprockets, test_unit
- replaces `gem 'rails'` with `railties`, `activerecord`, `actionpack`, `actionview`,
  `actionmailer`, `activejob` (all `7.1.5.1`), plus `sprockets-rails`
- regenerates `Gemfile.lock` without `activestorage`, `actionmailbox`, `actiontext`, `actioncable`
- deletes `config/storage.yml`

The lockfile was regenerated under Ruby 3.3.4 with the pin temporarily swapped. After step 2,
**rebase it onto the new Ruby and re-run `bundle lock`** rather than trusting it. Pin the component
gems to the 7.1.5.1 version step 2 leaves in place.

**Verify:**
- CI green, including the production boot. Eager loading proves nothing still references the
  removed frameworks.
- `RAILS_ENV=production SECRET_KEY_BASE=dummy bin/rails runner 'p defined?(ActiveStorage)'` prints
  `nil`.
- `grep activestorage Gemfile.lock` finds nothing.
- Smoke test passes.
- **After merge:** Dependabot closes #162, #154–156, #170–172 and #168. Check with
  `gh api repos/dubilla/Ampas/dependabot/alerts/162 --jq .state`.

Later Rails steps keep the component-gem style. Bump every component gem together.

## Step 4: Rails 7.1 → 7.2

Bump the component gems, run `bin/rails app:update` (review every diff; don't accept blindly), and
keep `load_defaults 7.1` until the app is green, then flip to 7.2. Fix deprecations. Run the
verification.

## Step 5: Rails 7.2 → 8.0

Same procedure. This is the heaviest step, because of the front-end decision from the old plan:

- *Minimal:* keep Sprockets + jQuery + Turbolinks.
- *Modern (recommended):* Propshaft + `turbo-rails`, drop jQuery / `jquery_ujs` / Turbolinks.
  `method: :delete` links become `data: { turbo_method: :delete }`, starting with Logout in the
  layout.

If going modern, add one or two Capybara JS specs (sign in, log out) in this PR, since nothing else
exercises JavaScript. Check Devise's Turbo notes (`config.responder`, `navigational_formats`).

## Step 6: Ruby 3.3 → 3.4

Install 3.4.x (latest patch) the same way as step 2. Bump `.ruby-version`, `Gemfile`, and `ci.yml`,
then run `bundle update --ruby`. Watch for gems that dropped stdlib defaults in 3.4.

## Step 7: Rails 8.0 → 8.1

Same procedure as steps 4–5. Afterwards, re-check Dependabot and triage whatever is left
individually: rack, puma, loofah, nokogiri, crass, net-imap.

## Step 8: Deploy to Heroku

The `heroku` git remote exists (`ampas`). Production is dead: no dynos, database detached Dec 2022,
last deploy March 2018. These cost money, so confirm before doing any of them.

- `heroku stack` should be heroku-24 (`heroku stack:set heroku-24`).
- `heroku addons:create heroku-postgresql:essential-0`.
- Add a `Procfile` (`web: bundle exec puma -p $PORT -e $RAILS_ENV`). The buildpack sets
  `SECRET_KEY_BASE` and `RAILS_SERVE_STATIC_FILES`.
- Push, then `heroku run rails db:schema:load`. The database starts empty, so `db/seeds.rb` (or a
  new task) needs to bootstrap a real ceremony.
- Consider re-enabling `config.force_ssl = true`.

---

## Outside the ladder (do anytime, own PR)

- **Local toolchain: rbenv only, arm64 Homebrew only.** Machine setup, not a repo change, but it
  removes the workarounds step 2 needed. Going forward, rbenv is the only Ruby manager.
  1. `/opt/homebrew/bin/brew install rbenv ruby-build`. Today both come from the Intel Homebrew.
  2. Remove rvm: `rvm implode`, then delete the rvm lines from `~/.profile` and `~/.bash_profile`.
     New shells should have no `GEM_HOME`/`GEM_PATH`.
  3. Back up the old Postgres data in `/usr/local/var` (`postgres`, `postgresql@10/12/14`), which
     came over from the Intel Mac.
  4. Remove the Intel Homebrew with the official `uninstall.sh --path=/usr/local`. Don't use its
     `brew uninstall` or `brew services`: it shares launch agent names with the arm64 Homebrew and
     would stop the arm64 Postgres. Reinstall anything still needed (redis, yarn, …) with the arm64
     brew, and drop `/usr/local/opt/postgresql@12/bin` from `PATH`.
  5. **Verify:** `which -a ruby brew pg_config pkg-config` shows no `/usr/local` or `.rvm` paths, and
     a clean `rbenv install` and `bundle install` work without the step 2 flags.

- **Authorization hole:** `EntriesController#update` never calls `authorize`, so any signed-in user
  can rewrite anyone's picks, even after the pool locks. `spec/requests/entries_spec.rb` asserts the
  broken behavior. Fix: add `authorize entry` and flip that spec to expect
  `Pundit::NotAuthorizedError`.
- **Stale Gemfile comments:** the `ffi < 1.17` pin says to drop it once Ruby 3.3 lands (it has).
  The terser comment cites Active Storage's JS as its reason, which step 3 removes.

## Progress log

| Date | Step | Notes |
|---|---|---|
| 2026-11-13 | — | Ladder planned. Step 3 work prepared and stashed, unverified. |
| 2026-11-13 | 1 | [#8](https://github.com/dubilla/Ampas/pull/8): CI now runs `zeitwerk:check`, a production boot, and `assets:precompile`. No `DATABASE_URL` needed. Didn't run the optional deliberate-failure check. |
