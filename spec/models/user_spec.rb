require 'rails_helper'

RSpec.describe User do
  it "deletes the user's entries and their picks when the account is destroyed" do
    entry = create(:entry)
    create(:pick, entry: entry)

    expect { entry.user.destroy }
      .to change(Entry, :count).by(-1)
      .and change(Pick, :count).by(-1)
  end
end
