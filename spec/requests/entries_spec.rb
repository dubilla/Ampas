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

    it 'denies the form after the pool has locked' do
      sign_in_as(owner)

      after_lock { expect { get new_pool_entry_path(pool) }.to raise_error(Pundit::NotAuthorizedError) }
    end

    it 'denies the form to a user who already has an entry in the pool' do
      entry_for(owner)
      sign_in_as(owner)

      expect { get new_pool_entry_path(pool) }.to raise_error(Pundit::NotAuthorizedError)
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

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'rejects a nominee from a different category' do
      sign_in_as(owner)
      other_category = ceremony.categories.last

      expect {
        post pool_entries_path(pool), params: { entry: { picks_attributes: pick_params(nominee_for: ->(_c) { other_category.nominees.first.id }) } }
      }.not_to change(Entry, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'rejects two picks for the same category' do
      sign_in_as(owner)
      category = ceremony.categories.first
      picks = { '0' => { category_id: category.id, nominee_id: category.nominees.first.id },
                '1' => { category_id: category.id, nominee_id: category.nominees.last.id } }

      expect {
        post pool_entries_path(pool), params: { entry: { picks_attributes: picks } }
      }.not_to change(Entry, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'denies a new entry after the pool has locked' do
      sign_in_as(owner)

      after_lock do
        expect {
          post pool_entries_path(pool), params: { entry: { picks_attributes: pick_params(nominee_for: ->(c) { c.nominees.first.id }) } }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
      expect(Entry.count).to eq(0)
    end

    it 'denies a second entry in the same pool' do
      entry_for(owner)
      sign_in_as(owner)

      expect {
        post pool_entries_path(pool), params: { entry: { picks_attributes: pick_params(nominee_for: ->(c) { c.nominees.first.id }) } }
      }.to raise_error(Pundit::NotAuthorizedError)
      expect(owner.entries.count).to eq(1)
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

    it "can't reach another entry's picks through nested attributes" do
      entry = entry_for(owner)
      other_entry = entry_for(create(:user))
      sign_in_as(owner)

      expect {
        patch entry_path(entry), params: { entry: { picks_attributes: change_picks_to_losers(other_entry) } }
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(other_entry.reload.score).to eq(ceremony.categories.count)
    end

    it "rejects extra id-less picks that would inflate the score" do
      entry = entry_for(owner)
      sign_in_as(owner)
      extra = entry.picks.each_with_index.to_h do |pick, index|
        [index.to_s, { category_id: pick.category_id, nominee_id: pick.nominee_id }]
      end

      patch entry_path(entry), params: { entry: { picks_attributes: extra } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(entry.reload.picks.count).to eq(ceremony.categories.count)
      expect(entry.score).to eq(ceremony.categories.count)
    end

    it 'requires authentication' do
      entry = entry_for(owner)

      patch entry_path(entry), params: { entry: { picks_attributes: change_picks_to_losers(entry) } }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "denies a stranger and leaves the owner's picks alone" do
      entry = entry_for(owner)
      sign_in_as(create(:user))

      expect {
        patch entry_path(entry), params: { entry: { picks_attributes: change_picks_to_losers(entry) } }
      }.to raise_error(Pundit::NotAuthorizedError)
      expect(entry.reload.score).to eq(ceremony.categories.count)
    end

    it 'denies the owner after lock' do
      entry = entry_for(owner)
      sign_in_as(owner)

      after_lock do
        expect {
          patch entry_path(entry), params: { entry: { picks_attributes: change_picks_to_losers(entry) } }
        }.to raise_error(Pundit::NotAuthorizedError)
        expect(entry.reload.score).to eq(ceremony.categories.count)
      end
    end
  end
end
