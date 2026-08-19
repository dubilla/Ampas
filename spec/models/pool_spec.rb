require 'rails_helper'

RSpec.describe Pool do
  describe '#locked?' do
    it 'tracks the ceremony lock time' do
      ceremony = create(:award_ceremony, locks_at: Time.current + 1.hour)
      pool = create(:pool, award_ceremony: ceremony)

      expect(pool).not_to be_locked
      Timecop.travel(ceremony.locks_at + 1.minute) { expect(pool).to be_locked }
    end
  end

  describe 'associations' do
    it 'reaches categories through the award ceremony' do
      ceremony = create(:award_ceremony, :with_categories, category_count: 3, nominee_count: 1)
      expect(create(:pool, award_ceremony: ceremony).categories.count).to eq(3)
    end

    it 'exposes the ceremony name with a prefix' do
      ceremony = create(:award_ceremony, name: 'The 90th Academy Awards')
      expect(create(:pool, award_ceremony: ceremony).award_ceremony_name).to eq('The 90th Academy Awards')
    end
  end
end
