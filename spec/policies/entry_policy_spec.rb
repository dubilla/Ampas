require 'rails_helper'

RSpec.describe EntryPolicy do
  let(:owner) { create(:user) }
  let(:stranger) { create(:user) }
  let(:ceremony) { create(:award_ceremony, locks_at: Time.current + 1.hour) }
  let(:entry) { create(:entry, pool: create(:pool, award_ceremony: ceremony), user: owner) }

  def after_lock
    Timecop.travel(ceremony.locks_at + 1.minute) { yield }
  end

  describe '#show?' do
    it 'allows the owner before lock' do
      expect(described_class.new(owner, entry).show?).to be(true)
    end

    it 'denies a stranger before lock' do
      expect(described_class.new(stranger, entry).show?).to be(false)
    end

    # Entries become public once picks can no longer change.
    it 'allows a stranger after lock' do
      after_lock { expect(described_class.new(stranger, entry).show?).to be(true) }
    end

    it 'denies a signed-out visitor before lock' do
      expect(described_class.new(nil, entry).show?).to be(false)
    end

    it 'allows a signed-out visitor after lock' do
      after_lock { expect(described_class.new(nil, entry).show?).to be(true) }
    end
  end

  describe '#update?' do
    it 'allows the owner before lock' do
      expect(described_class.new(owner, entry).update?).to be(true)
    end

    it 'denies the owner after lock' do
      after_lock { expect(described_class.new(owner, entry).update?).to be(false) }
    end

    it 'denies a stranger' do
      expect(described_class.new(stranger, entry).update?).to be(false)
    end
  end

  describe '#edit?' do
    it 'allows the owner before lock' do
      expect(described_class.new(owner, entry).edit?).to be(true)
    end

    it 'denies the owner after lock' do
      after_lock { expect(described_class.new(owner, entry).edit?).to be(false) }
    end

    it 'denies a stranger' do
      expect(described_class.new(stranger, entry).edit?).to be(false)
    end

    it 'denies a signed-out visitor' do
      expect(described_class.new(nil, entry).edit?).to be(false)
    end
  end
end
