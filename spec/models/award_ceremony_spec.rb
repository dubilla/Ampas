require 'rails_helper'

RSpec.describe AwardCeremony do
  it 'requires a lock time' do
    ceremony = build(:award_ceremony, locks_at: nil)

    expect(ceremony).not_to be_valid
    expect(ceremony.errors[:locks_at]).to include("can't be blank")
  end

  it 'is backed by a NOT NULL column' do
    ceremony = build(:award_ceremony, locks_at: nil)

    expect { ceremony.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
  end
end
