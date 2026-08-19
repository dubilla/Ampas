require 'rails_helper'

RSpec.describe Entry do
  # Builds a ceremony/pool/entry where the entry has one pick per category.
  # `winning:` controls how many of those picks land on the winning nominee.
  def entry_with_picks(winning:, categories: 3)
    ceremony = create(:award_ceremony, :with_categories, category_count: categories, nominee_count: 2)
    pool = create(:pool, award_ceremony: ceremony)
    entry = create(:entry, pool: pool)

    ceremony.categories.each_with_index do |category, index|
      nominee = index < winning ? category.nominees.detect(&:winner?) : category.nominees.reject(&:winner?).first
      create(:pick, entry: entry, category: category, nominee: nominee)
    end

    entry.reload
  end

  describe '#score' do
    it 'counts picks landing on a winning nominee' do
      expect(entry_with_picks(winning: 2, categories: 3).score).to eq(2)
    end

    it 'is zero when no pick won' do
      expect(entry_with_picks(winning: 0, categories: 3).score).to eq(0)
    end

    it 'is zero for an entry with no picks' do
      expect(create(:entry).score).to eq(0)
    end
  end

  describe '#locked?' do
    let(:ceremony) { create(:award_ceremony, locks_at: Time.current + 1.hour) }
    let(:entry) { create(:entry, pool: create(:pool, award_ceremony: ceremony)) }

    it 'is false before locks_at' do
      expect(entry).not_to be_locked
    end

    it 'is true once locks_at has passed' do
      Timecop.travel(ceremony.locks_at + 1.minute) { expect(entry).to be_locked }
    end

    it 'is true exactly at locks_at (boundary is inclusive)' do
      Timecop.freeze(ceremony.locks_at) { expect(entry).to be_locked }
    end
  end

  describe 'delegation' do
    it 'exposes the user email as #name' do
      user = create(:user, email: 'someone@example.com')
      expect(create(:entry, user: user).name).to eq('someone@example.com')
    end

    it 'delegates award_ceremony and locks_at through the pool' do
      ceremony = create(:award_ceremony)
      entry = create(:entry, pool: create(:pool, award_ceremony: ceremony))
      expect(entry.award_ceremony).to eq(ceremony)
      expect(entry.locks_at).to eq(ceremony.locks_at)
      expect(entry.award_ceremony_name).to eq(ceremony.name)
    end
  end

  describe 'picks' do
    it 'orders picks by creation time' do
      entry = create(:entry)
      first = create(:pick, entry: entry, created_at: 2.days.ago)
      second = create(:pick, entry: entry, created_at: 1.day.ago)
      expect(entry.reload.picks.to_a).to eq([first, second])
    end

    it 'destroys dependent picks when the association is fresh' do
      entry = create(:entry)
      create(:pick, entry: entry)

      expect { entry.reload.destroy }.to change(Pick, :count).by(-1)
    end

    # CHARACTERIZATION -- this records a real latent bug, not desired behavior.
    #
    # `validates_associated :picks` loads and caches the picks association during
    # Entry.create!. Picks added afterwards do not invalidate that cache, so
    # `dependent: :destroy` iterates a stale empty array, deletes nothing, and the
    # DELETE then trips the picks->entries foreign key.
    #
    # Latent today only because nothing in the app destroys an entry: there is no
    # destroy action and no route for one. Left as-is so the upgrade is a pure
    # behavior-preserving change.
    #
    # TODO(post-upgrade): fix by reloading before destroy, or by replacing
    # `dependent: :destroy` with `dependent: :delete_all`.
    it 'fails to destroy picks when the association cache is stale' do
      entry = create(:entry)
      create(:pick, entry: entry)

      expect { entry.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it 'accepts nested attributes for picks' do
      category = create(:category)
      nominee = create(:nominee, category: category)
      entry = Entry.new(pool: create(:pool), user: create(:user))
      entry.picks_attributes = [{ category_id: category.id, nominee_id: nominee.id }]
      expect(entry.save).to be(true)
      expect(entry.picks.count).to eq(1)
    end

    it 'is invalid when an associated pick is invalid' do
      entry = Entry.new(pool: create(:pool), user: create(:user))
      entry.picks_attributes = [{ category_id: create(:category).id, nominee_id: nil }]
      expect(entry).not_to be_valid
    end
  end
end
