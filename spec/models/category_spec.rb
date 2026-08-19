require 'rails_helper'

RSpec.describe Category do
  describe '#winner' do
    it 'returns the nominee flagged as winner' do
      category = create(:category)
      create(:nominee, category: category, winner: false)
      winner = create(:nominee, category: category, winner: true)

      expect(category.reload.winner).to eq(winner)
    end

    it 'returns nil when no nominee has won yet' do
      category = create(:category)
      create(:nominee, category: category, winner: false)

      expect(category.reload.winner).to be_nil
    end

    it 'treats a null winner flag as not winning' do
      category = create(:category)
      create(:nominee, category: category, winner: nil)

      expect(category.reload.winner).to be_nil
    end
  end
end
