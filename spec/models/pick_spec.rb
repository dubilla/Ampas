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

  # Characterization: nothing currently requires a pick's nominee to belong to
  # the pick's category. Recorded as-is; see TODO in the upgrade plan.
  it 'permits a nominee from an unrelated category' do
    expect(build(:pick, category: create(:category), nominee: create(:nominee))).to be_valid
  end
end
