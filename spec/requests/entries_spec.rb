require 'rails_helper'

RSpec.describe 'Entries', type: :request do
  let(:ceremony) { create(:award_ceremony, :with_categories, category_count: 2, nominee_count: 3) }
  let(:pool) { create(:pool, award_ceremony: ceremony) }
  let(:owner) { create(:user) }

  def entry_for(user, ceremony_for_picks: ceremony)
    entry = create(:entry, pool: pool, user: user)
    ceremony_for_picks.categories.each do |category|
      create(:pick, entry: entry, category: category, nominee: category.nominees.first)
    end
    entry.reload
  end

  def after_lock
    Timecop.travel(ceremony.locks_at + 1.minute) { yield }
  end

  describe 'GET /pools/:pool_id/entries/new' do
    it 'requires authentication' do
      get new_pool_entry_path(pool)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'builds one pick per category on the ceremony' do
      sign_in_as(owner)
      get new_pool_entry_path(pool)

      expect(response).to have_http_status(:ok)
      ceremony.categories.each { |category| expect(response.body).to include(category.name) }
      # One select per category.
      expect(response.body.scan(/name="entry\[picks_attributes\]/).size).to be >= ceremony.categories.count
    end
  end

  describe 'POST /pools/:pool_id/entries' do
    def pick_params(nominee_for:)
      ceremony.categories.each_with_index.each_with_object({}) do |(category, index), acc|
        acc[index.to_s] = { category_id: category.id, nominee_id: nominee_for.call(category) }
      end
    end

    it 'creates an entry owned by the current user' do
      sign_in_as(owner)

      expect {
        post pool_entries_path(pool), params: { entry: { picks_attributes: pick_params(nominee_for: ->(c) { c.nominees.first.id }) } }
      }.to change(Entry, :count).by(1)

      entry = Entry.last
      expect(entry.user).to eq(owner)
      expect(entry.pool).to eq(pool)
      expect(entry.picks.count).to eq(ceremony.categories.count)
      expect(response).to redirect_to(entry_path(entry))
    end

    it 're-renders the form when a pick has no nominee' do
      sign_in_as(owner)

      expect {
        post pool_entries_path(pool), params: { entry: { picks_attributes: pick_params(nominee_for: ->(_c) { nil }) } }
      }.not_to change(Entry, :count)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /entries/:id' do
    it 'shows the owner their entry' do
      entry = entry_for(owner)
      sign_in_as(owner)

      get entry_path(entry)

      expect(response).to have_http_status(:ok)
    end

    it 'denies a stranger before lock' do
      entry = entry_for(owner)
      sign_in_as(create(:user))

      expect { get entry_path(entry) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'opens the entry to everyone once the pool locks' do
      entry = entry_for(owner)
      sign_in_as(create(:user))

      after_lock do
        get entry_path(entry)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /entries/:id/edit' do
    it 'lets the owner edit before lock' do
      entry = entry_for(owner)
      sign_in_as(owner)

      get edit_entry_path(entry)

      expect(response).to have_http_status(:ok)
    end

    it 'denies the owner after lock' do
      entry = entry_for(owner)
      sign_in_as(owner)

      after_lock { expect { get edit_entry_path(entry) }.to raise_error(Pundit::NotAuthorizedError) }
    end

    it 'denies a stranger' do
      entry = entry_for(owner)
      sign_in_as(create(:user))

      expect { get edit_entry_path(entry) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe 'PATCH /entries/:id' do
    def change_picks_to_losers(entry)
      entry.picks.each_with_object({}) do |pick, acc|
        loser = pick.category.nominees.reject(&:winner?).first
        acc[pick.id.to_s] = { id: pick.id, category_id: pick.category_id, nominee_id: loser.id }
      end
    end

    it 'lets the owner change their picks' do
      entry = entry_for(owner)
      sign_in_as(owner)

      patch entry_path(entry), params: { entry: { picks_attributes: change_picks_to_losers(entry) } }

      expect(response).to redirect_to(entry_path(entry))
      expect(entry.reload.score).to eq(0)
    end

    it 'requires authentication' do
      entry = entry_for(owner)

      patch entry_path(entry), params: { entry: { picks_attributes: change_picks_to_losers(entry) } }

      expect(response).to redirect_to(new_user_session_path)
    end

    # CHARACTERIZATION -- this records a real authorization hole, not desired behavior.
    #
    # EntriesController#update never calls `authorize`, unlike #show and #edit. Any
    # authenticated user can therefore rewrite any other user's picks, including
    # after the pool has locked. Recorded as-is so the upgrade stays behavior-
    # preserving; see docs/rails-upgrade-plan.md.
    #
    # TODO(post-upgrade): add `authorize entry` to #update and flip these two
    # examples to expect Pundit::NotAuthorizedError.
    it "allows any signed-in user to rewrite another user's picks" do
      entry = entry_for(owner)
      sign_in_as(create(:user))

      patch entry_path(entry), params: { entry: { picks_attributes: change_picks_to_losers(entry) } }

      expect(response).to redirect_to(entry_path(entry))
      expect(entry.reload.score).to eq(0)
    end

    it 'allows edits after the pool has locked' do
      entry = entry_for(owner)
      sign_in_as(owner)

      after_lock do
        patch entry_path(entry), params: { entry: { picks_attributes: change_picks_to_losers(entry) } }
        expect(entry.reload.score).to eq(0)
      end
    end
  end
end
