require 'rails_helper'

RSpec.describe Pick do
  it 'is valid with a nominee' do
    expect(build(:pick)).to be_valid
  end

  it 'is invalid without a nominee' do
    pick = build(:pick, nominee: nil)

    expect(pick).not_to be_valid
    expect(pick.errors[:nominee]).to include('is missing')
  end

  it 'is invalid with a nominee from another category' do
    pick = build(:pick)
    pick.nominee = create(:nominee)

    expect(pick).not_to be_valid
    expect(pick.errors[:nominee]).to include('is not in this category')
  end

  it "is invalid with a category from another ceremony than the entry's" do
    pick = build(:pick)
    pick.category = create(:category)
    pick.nominee = create(:nominee, category: pick.category)

    expect(pick).not_to be_valid
    expect(pick.errors[:category]).to include('is not part of this award ceremony')
  end
end
