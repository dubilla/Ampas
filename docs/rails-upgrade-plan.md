# Ampas: Ruby + Rails Upgrade Plan

**Status:** Phase 0 complete — app boots and serves locally on Rails 4.2
**Goal:** Get from Ruby 2.6.10 / Rails 4.2.8 to Ruby 3.3 / Rails 8.0, closing ~100 open Dependabot
alerts (including [#135](https://github.com/dubilla/Ampas/security/dependabot/135), the nokogiri
CSS-tokenizer ReDoS that requires Ruby >= 3.2 to patch).
**Shape:** Long-lived, resumable. Each phase is a stop point — the app boots and works at the end of
every one. Pick it up and put it down freely.

---

## Ground truth (verified 2026-08-17)

Read this before planning any work. Several assumptions you might reasonably hold are false.

### Production is not running

```
$ heroku apps:info -a ampas
Dynos:  (none)
Stack:  cedar-14 (next build will use heroku-24)

$ heroku addons -a ampas
No add-ons for app ampas.

$ heroku releases -a ampas
v39  Detach DATABASE   2022/12/03   <- database removed
v37  Deploy 0f3540eb   2018/03/04   <- last actual code deploy
```

There are **no dynos, no addons, and no database**. The Postgres addon was detached in December 2022;
last real deploy was March 2018. The stack is `cedar-14`, EOL since 2019.

**Consequences:**
- **There is no live attack surface.** Every Dependabot alert on this repo, #135 included, is
  theoretical. Nothing is exposed because nothing is running. Treat this work as *revival*, not
  *incident response* — it changes the urgency, not the value.
- **There is no production data to preserve.** `script/restore_dev_db.sh` pulls from a Heroku PG
  backup that no longer exists. Verify whether a local `ampas_development` database still holds
  anything you care about (Phase 0); assume not.
- **Redeploying requires this upgrade anyway.** `cedar-14` is gone; the next build lands on
  `heroku-24`, which requires Ruby >= 3.1. Rails 4.2 / Ruby 2.6 literally cannot deploy to Heroku
  today. The upgrade is the price of admission for ever running this app again.

### There are zero tests

`rspec-rails` is in the Gemfile and the README claims "Run tests: `bundle exec rspec`", but:

- No `spec/` directory exists at all.
- `test/` contains only `.keep` files and a stock `test_helper.rb`.

**This is the single largest risk in the project.** A five-hop framework upgrade with no regression
suite is a guessing game. Phase 1 exists to fix this and is non-negotiable.

### The app is small

This is the good news, and it makes the whole thing tractable:

| Thing | Count |
|---|---|
| Models | 6 (`AwardCeremony`, `Category`, `Entry`, `Nominee`, `Pick`, `Pool`, `User`) |
| Controllers | 3 app + 6 Devise subclasses (5 of which are pure stock boilerplate) |
| Views | ~10 app + Devise |
| Policies | 2 (Pundit) |
| Migrations | 19 |
| DB tables | 8 |
| Custom JS | none (manifest only: jquery, jquery_ujs, turbolinks) |
| Custom Rake tasks | none |
| Background jobs / mailers | none |

There is no Nokogiri usage anywhere in `app/`, `lib/`, or `config/` — it arrives only transitively
via `loofah` / `rails-html-sanitizer` (HTML sanitization) and `rails-dom-testing` (test-only).

### Local toolchain

- Current Ruby is **macOS system Ruby 2.6.10** (`universal.arm64e-darwin25`) — not rbenv-managed.
  Apple deprecated this; it can disappear in an OS update, and building native gems (`pg`,
  `nokogiri`) against it on arm64 macOS 26 is fragile.
- rbenv has: `2.7.8`, `3.1.6`, `3.3.4`, `3.3.11`.
- Bundler is **1.17.2** (Rails 4.2 pins `bundler >= 1.3.0, < 2.0`).
- No `.ruby-version` file, no `ruby` directive in the Gemfile, no CI, no Procfile.

---

## Target end state

| | From | To |
|---|---|---|
| Ruby | 2.6.10 (system) | 3.3.11 (rbenv) |
| Rails | 4.2.8 | 8.0.x |
| Bundler | 1.17.2 | 2.x |
| Nokogiri | 1.8.2 | >= 1.19.3 (closes #135) |
| Test suite | none | RSpec, characterization coverage of every user-facing path |
| CI | none | GitHub Actions running specs on push |
| Deploy | cedar-14, dead | heroku-24 (or a decision not to redeploy) |

---

## Strategy: a compressed ladder

Conventional advice is one Rails minor at a time. That's calibrated for large apps; with 6 models and
3 real controllers, the per-hop overhead dominates and you'd spend more time on ceremony than on
fixes. **Four hops:**

```
Rails 4.2.8  ──▶  5.2  ──▶  6.1  ──▶  7.1  ──▶  8.0
Ruby  2.6 (docker) ─┴──▶ 2.7.8 ─┴──▶ 3.3.11 ─┴──▶ 3.3.11
```

Still read every intermediate version's official upgrade guide (5.0, 5.1, 5.2 for the first hop, etc.)
— you're skipping the *deploys*, not the *changelogs*.

Rails/Ruby compatibility constraints driving the pairing:

- Rails 4.2 does **not** run on Ruby 2.7 (`BigDecimal.new` was removed). Ruby 2.6 is the ceiling until
  Rails 5.
- Rails 5.2 supports Ruby 2.2.2–2.6.
- Rails 6.1 supports Ruby 2.5–3.0 → first chance to move to rbenv 2.7.8 natively.
- Rails 7.1 supports Ruby 2.7–3.3 → move to 3.3.11.
- Rails 8.0 requires Ruby >= 3.2.
- Nokogiri >= 1.19.0 requires Ruby >= 3.2 — **only reachable at the very end.**

### Running Rails 4.2 locally (RESOLVED — no Docker needed)

An earlier draft of this plan recommended Docker for the Ruby 2.6 phases. **That turned out to be
unnecessary.** The app now boots and serves traffic natively on macOS 26 / arm64 / system Ruby 2.6.10.
Two blockers had to be cleared, both worth knowing about:

**Blocker 1 — `nokogiri 1.8.2` cannot compile.** It vendors libxml2 2.9.x, which will not build against
the modern clang/macOS SDK. Fixed by bumping to `1.13.10`, the highest release supporting Ruby 2.6.
This is Rails-4.2-safe (`rails-dom-testing` only requires `~> 1.6`) and independently closes most of
the repo's 30 open nokogiri advisories.

**Blocker 2 — the arm64/x86_64 platform trap.** System Ruby is a universal binary reporting
`Gem::Platform.local == universal-darwin-25`. RubyGems' fuzzy platform matching resolved that to the
**x86_64** precompiled nokogiri on an **arm64** machine, producing a confusing
`cannot load such file -- nokogiri/nokogiri (LoadError)` at boot. Fixed with:

```bash
bundle config --local force_ruby_platform true
```

which compiles from source against the real CPU. **Any precompiled native gem hits this same trap on
system Ruby** — expect it again on future bumps, and treat it as another argument for moving to an
rbenv Ruby in Phase 3.

**Blocker 3 — `devise 4.2.0` is a syntax error on Ruby 2.6.** In
`devise/app/controllers/devise/sessions_controller.rb:5`:

```ruby
prepend_before_action only: [:create, :destroy] { request.env["devise.skip_timeout"] = true }
```

A brace block following an unparenthesized hash argument stopped parsing in Ruby 2.6. This failed
*inside middleware with no backtrace* — `/users/sign_in` returned a bare 500 and the log showed
`Started GET` with no `Processing by` line. Fixed by bumping Devise to `~> 4.7.3` (fixed upstream in
4.4.0), which still supports Rails 4.2.

Lesson for later phases: when a route 500s with no backtrace, the failure is in middleware or gem
load. Force it into the open with an `ActionDispatch::Integration::Session` under
`config.action_dispatch.show_exceptions = false`.

---

## Phase 0 — Decide and set the baseline

**Why first:** don't spend a weekend on a ladder you don't want to climb.

- [ ] **Decide whether to revive at all.** The app has been down for 3+ years with no data. Valid
      outcomes: (a) do this upgrade, (b) archive the repo and dismiss the alerts, (c) rebuild
      greenfield (see *Alternative* below). Everything past this point assumes (a).
- [x] Check whether a local `ampas_development` database still exists and holds real data
      (`psql -l | grep ampas`). If yes, `pg_dump` it somewhere safe — it may be the only surviving copy.
- [ ] Create the branch: `git checkout -b upgrade/rails-8`.
- [x] ~~Add `Dockerfile.upgrade`~~ Not needed — runs natively; see above.
- [ ] ~~Docker~~ + `docker-compose.yml` (Ruby 2.6.10 + Postgres 11). Confirm
      `bundle install` and `bin/rails console` work inside it.
- [x] Confirm the app actually boots and serves a page today, seeded from `db/seeds.rb` +
      `db/structure.sql`. **If it doesn't boot on 4.2, fix that before changing anything** — you cannot
      characterize behavior you can't run.
- [ ] Take screenshots of every page (home, sign in/up, pools index, pool show, entry new/show/edit).
      These become your visual regression reference; the styling is vendored Bourbon/Neat/Bitters and
      will be the least-tested thing you touch.

**Done when:** the Rails 4.2 app boots in Docker, you can sign up, create an entry, and you have
before-screenshots committed to `docs/screenshots/`.

---

## Phase 1 — Build the safety net

**Why:** this is the whole ballgame. Every later phase is "change framework, run specs, fix red."
Without specs you are upgrading blind on an app you last touched in 2018.

Write **characterization tests** — they encode what the app *currently does*, bugs included. Do not
fix behavior here. If you find something that looks wrong, write a spec asserting the current wrong
behavior and add a `# TODO(upgrade): looks like a bug, revisit post-upgrade` comment.

- [ ] Create `spec/`, `spec/rails_helper.rb`, `spec/spec_helper.rb` (`rails g rspec:install`).
- [ ] Add `factory_bot_rails`, `capybara`, `database_cleaner-active_record` to the `:test` group.
- [ ] Factories for all 6 models, plus a `pool_with_categories` trait — most specs need a ceremony
      with categories and nominees.

**Model specs** (`spec/models/`):
- [ ] `Entry#score` — counts picks whose nominee is a winner.
- [ ] `Entry#locked?` and `Pool#locked?` — delegate through to `award_ceremony.locks_at`; test both
      sides of the boundary with `travel_to`.
- [ ] `Entry#name` — delegates to `user.email`.
- [ ] `Category#winner` — note this uses `nominees.find(&:winner?)`, the *Enumerable* `find`, not the
      AR one. Preserve that; it returns `nil` with no winner.
- [ ] `Pick#complete?` validation — invalid without a nominee.
- [ ] `Entry` `validates_associated :picks` + `accepts_nested_attributes_for :picks`.

**Policy specs** (`spec/policies/entry_policy_spec.rb`):
- [ ] `show?` — true if the user owns the entry, **or** if the entry is locked (public after lock).
- [ ] `edit?` — true only if the user owns it **and** it's not locked.
- [ ] Nil-user cases. `edit?` currently calls `user.entries` with no nil guard — if that raises
      today, assert that it raises.

**Request/feature specs** (`spec/requests/` or `spec/features/`):
- [ ] Sign up, sign in, sign out (Devise).
- [ ] `HomeController#index` — redirects to `pools_path` when the user has pools, renders otherwise.
- [ ] `PoolsController#index` — redirects to root when signed out; lists the user's pools when in.
- [ ] `PoolsController#show`.
- [ ] `EntriesController#new` — builds one `Pick` per category on the pool's ceremony. This is the
      most intricate code in the app; cover it well.
- [ ] `EntriesController#create` — happy path redirects to the entry; invalid re-renders `new`.
- [ ] `EntriesController#update` — happy path and invalid path.
- [ ] `EntriesController#show` / `#edit` authorization — a non-owner is rejected on an unlocked entry.
- [ ] `ApplicationController#after_sign_in_path_for` — the referer logic (returns to referer unless
      the referer *is* the sign-in page). Easy to break silently in a Devise upgrade.
- [ ] Layout switching — `devise` layout on Devise controllers, `application` elsewhere.

**Done when:** `bundle exec rspec` is green, and coverage includes every route in `config/routes.rb`.
Commit. **This is a good long stop point.**

---

## Phase 2 — Rails 4.2.8 → 5.2

The biggest hop. Ruby stays at 2.6 (Docker). Read the 4.2→5.0, 5.0→5.1, and 5.1→5.2 upgrade guides.

- [ ] Bundler 1.17 → 2.x (Rails 5 lifts the `< 2.0` pin).
- [ ] `gem 'rails', '5.2.8.1'`; `bundle update rails`.
- [ ] Run `rails app:update`, diffing every file rather than accepting wholesale — `config/` here is
      still mostly stock 4.2 scaffolding with the comments intact.
- [ ] **Delete `config.active_record.raise_in_transactional_callbacks`** from `config/application.rb`
      — removed in Rails 5.0; the app won't boot with it.
- [ ] Add `config.load_defaults 5.2` and work through `new_framework_defaults.rb`.
- [ ] **`belongs_to` is required by default in Rails 5.** This will break things. Affected:
      `Pick belongs_to :entry, :category, :nominee` (picks are built unsaved with a nil nominee in
      `EntriesController#new` — this *will* fail validation), `Nominee belongs_to :category`,
      `Entry belongs_to :pool, :user`, `Pool belongs_to :award_ceremony`,
      `Category belongs_to :award_ceremony`. Decide per association: add `optional: true` where nil is
      legitimately allowed (`Pick#nominee` certainly is — the whole point of `#new` is empty picks), or
      set `config.active_record.belongs_to_required_by_default = false` as a temporary escape hatch and
      revisit. Your Phase 1 specs will tell you exactly which ones matter.
- [ ] Add `app/models/application_record.rb`; reparent all 6 models from `ActiveRecord::Base`.
- [ ] Add `app/controllers/application_controller.rb`-adjacent `ApplicationJob`/`ApplicationMailer`
      only if `rails app:update` wants them (there are no jobs or mailers today).
- [ ] `config.serve_static_files` → `config.public_file_server.enabled` in
      `config/environments/production.rb`.
- [ ] `rails-deprecated_sanitizer` disappears from the tree — good.
- [ ] Devise 4.2 → 4.4+ (Rails 5 support). Regenerate `config/initializers/devise.rb` against the new
      version and re-apply your customizations by diff.
- [ ] `@entry.update_attributes(...)` in `EntriesController#update` → `update`. (Deprecated in 6.1,
      removed in 7.0 — do it now while it's harmless.)
- [ ] Verify `params.required(:entry)` still works (it's an alias of `require`; it survives, but
      confirm rather than assume).
- [ ] Regenerate `db/structure.sql` (`rails db:migrate` against a fresh DB) — the format changes.
- [ ] Turbolinks 2 → 5 (`data-turbolinks-track: true` → `'reload'` in
      `app/views/layouts/application.html.erb`).
- [ ] `bundle update` the long tail: `pg`, `pundit`, `sass-rails`, `uglifier`, `jquery-rails`,
      `web-console` (2.x → 3.x), `rspec-rails`, `rubocop`.
- [ ] Drop dead gems while you're here: `sdoc`, `refills`, `rails_best_practices`. Also drop the
      `bourbon`, `neat`, and `bitters` gems — **all three are already vendored** under
      `app/assets/stylesheets/`, so the gems are doing nothing.

**Done when:** specs green, app boots, screenshots match Phase 0. Commit and stop.

---

## Phase 3 — Rails 5.2 → 6.1, and Ruby 2.6 → 2.7.8

Two changes; do the Rails hop first, then the Ruby hop, as separate commits.

- [ ] `gem 'rails', '6.1.7.10'`; `rails app:update`; `config.load_defaults 6.1`.
- [ ] **Zeitwerk autoloading.** Rails 6 defaults to it. `Users::SessionsController` in
      `app/controllers/users/` already follows the convention, so this should be quiet — verify with
      `bin/rails zeitwerk:check`.
- [ ] `config/database.yml` — Rails 6 multi-database format is optional; the current single-database
      shape still works. Leave it unless something complains.
- [ ] Devise → 4.8.x.
- [ ] Sprockets 3 → 4: add `app/assets/config/manifest.js`. Without it, assets silently 404 in
      production. Screenshot-check this one.
- [ ] `sass-rails` → `sassc-rails` (libsass; the `sass` gem is EOL). Vendored Bourbon 4 / Neat 1.8 are
      SCSS-3 era and *usually* compile under SassC — but this is the highest-risk styling step in the
      project. If SassC chokes, the fallback is to compile the vendored stylesheets once and commit the
      resulting CSS, retiring the SCSS toolchain entirely. For an app with two custom stylesheets
      (`layouts/application.scss`, `entries/entries.scss`) that is a perfectly reasonable outcome.
- [ ] Regenerate `db/structure.sql` (6.1 changes the `pg_dump` invocation).
- [ ] **Then** bump Ruby: add `.ruby-version` with `2.7.8`, add `ruby '2.7.8'` to the Gemfile, exit
      Docker, `rbenv local 2.7.8`, `bundle install` natively.
- [ ] Fix Ruby 2.7 keyword-argument separation warnings (`ruby -W:deprecated`). With no metaprogramming
      in this codebase there should be few or none, but the gems will be noisy until they're all
      updated.

**Done when:** specs green natively on rbenv 2.7.8, `Dockerfile.upgrade` deleted, screenshots match.
Commit and stop.

---

## Phase 4 — Rails 6.1 → 7.1, and Ruby 2.7 → 3.3.11

- [ ] `rbenv local 3.3.11`, `.ruby-version` and Gemfile `ruby` directive to `3.3.11`.
- [ ] `gem 'rails', '7.1.5'`; `rails app:update`; `config.load_defaults 7.1`.
- [ ] **`update_attributes` is gone** — already handled in Phase 2 if you did it there.
- [ ] **`Rails.application.secrets` is removed in 7.1.** `config/secrets.yml` must go. Move
      `secret_key_base` to `config/credentials.yml.enc` or keep reading `ENV['SECRET_KEY_BASE']`
      directly. Note: the dev and test `secret_key_base` values are **committed in plaintext** in the
      public repo today. They're dev/test-only so the exposure is minimal, but rotate them as part of
      this step rather than carrying them forward.
- [ ] Pundit 1.1 → 2.x: `include Pundit` becomes `include Pundit::Authorization` in
      `app/controllers/application_controller.rb`.
- [ ] Devise → 4.9.x.
- [ ] `uglifier` → `terser`.
- [ ] Zeitwerk is now mandatory (classic autoloader removed). `bin/rails zeitwerk:check`.
- [ ] Ruby 3.x removals to grep for: `Fixnum`/`Bignum`, `URI.escape`, `Object#taint`. Unlikely in this
      codebase but cheap to check.
- [ ] `coffee-rails` → remove entirely. There are **zero `.coffee` files** in the app.
- [ ] **Nokogiri can now reach 1.18.x** (Ruby >= 3.1) — a large chunk of the 30 open nokogiri alerts
      closes here. Alert #135 still needs Rails 8 / Ruby 3.2+, one phase away.

**Done when:** specs green on Ruby 3.3.11, screenshots match. Commit and stop.

---

## Phase 5 — Rails 7.1 → 8.0, and close the alerts

- [ ] `gem 'rails', '8.0.x'`; `rails app:update`; `config.load_defaults 8.0`.
- [ ] **`bundle update nokogiri` → >= 1.19.3.** This closes
      [alert #135](https://github.com/dubilla/Ampas/security/dependabot/135) — the actual objective.
- [ ] Front-end decision. Rails 8 defaults to Propshaft + Turbo + Stimulus + importmaps. The app's JS
      is three sprockets directives and nothing else, so either path is cheap:
      - *Minimal:* keep Sprockets, keep jQuery + Turbolinks 5. Least work, most legacy.
      - *Modern:* Propshaft + `turbo-rails`, drop jQuery and `jquery_ujs`. Requires changing
        `link_to 'Logout', destroy_user_session_path, method: :delete` in the layout to
        `data: { turbo_method: :delete }`, and the same for any other `method:` links. **Recommended**
        — the surface is tiny and it retires four dependencies.
- [ ] Devise → 4.9.4+ (Rails 8 / Turbo compatible; check `config.responder` and the Turbo-related
      Devise notes).
- [ ] Run `bundle audit` / re-check the Dependabot dashboard. Expect the open-alert count to fall from
      ~100 to near zero. Triage whatever is left individually.
- [ ] Add `.github/workflows/ci.yml` — Postgres service, `bundle exec rspec`, `bundle exec rubocop`.
      Without CI this will silently rot again.
- [ ] Consider re-enabling `config.force_ssl = true` in production (currently commented out).
- [ ] Deploy decision: push to `heroku-24` with a fresh Postgres addon, or formally archive. If
      deploying, the DB is empty — `db/seeds.rb` will need to be able to bootstrap a real ceremony.
- [ ] Update `README.md` — it currently claims Rails 4.2.8, "Ruby 2.2.2 or higher", and a test suite
      that doesn't exist.

**Done when:** Dependabot alert count is near zero, CI is green on `master`, README is accurate.

---

## Alternative considered: greenfield rebuild

Worth stating plainly, because at this app's size it's a real contender rather than a strawman.

The domain is 8 tables and 3 controllers. `rails new ampas --database=postgresql` on Rails 8, then
porting 6 models, 2 policies, 3 controllers, and ~10 ERB templates, is plausibly **faster** than four
framework hops — and it lands on modern idioms (Solid Queue/Cache, Propshaft, Turbo, Kamal) instead of
2017 idioms wearing a Rails 8 costume.

**Rebuild wins if:** you want to actively develop this app again, and the 2017 patterns (jQuery,
Turbolinks, vendored Bourbon/Neat) aren't worth preserving.

**Upgrade wins if:** you value the git history and the guarantee that behavior is preserved exactly,
or you want the upgrade itself as the exercise.

**Note the asymmetry:** Phase 1 (the test suite) is required either way — it's the only thing that
proves a rebuild is faithful. So Phase 0 and Phase 1 are unconditional. **You do not have to choose
between these two paths until Phase 2 begins.** Do Phase 1 first, then decide.

---

## Progress log

Append a dated line as each phase closes.

| Date | Phase | Notes |
|---|---|---|
| 2026-08-18 | 0 | App revived locally. nokogiri 1.8.2 -> 1.13.10, devise 4.2.0 -> 4.7.3, `force_ruby_platform`. DB created from `structure.sql`, real `db/seeds.rb` written. All routes verified incl. authenticated sign-in -> pools -> entry. Docker deemed unnecessary. |
| | | |
