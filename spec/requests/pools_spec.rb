require 'rails_helper'

RSpec.describe 'Pools', type: :request do
  describe 'GET /pools' do
    it 'redirects a signed-out visitor to the root' do
      get '/pools'
      expect(response).to redirect_to(root_path)
    end

    it 'lists only the pools the signed-in user has entered' do
      user = create(:user)
      mine = create(:pool)
      theirs = create(:pool)
      create(:entry, pool: mine, user: user)
      create(:entry, pool: theirs, user: create(:user))

      sign_in_as(user)
      get '/pools'

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(pool_path(mine))
      expect(response.body).not_to include(pool_path(theirs))
    end
  end

  describe 'GET /pools/:id' do
    it 'offers a way to join and lists existing entries with their scores' do
      ceremony = create(:award_ceremony, :with_categories, category_count: 2, nominee_count: 2)
      pool = create(:pool, award_ceremony: ceremony)
      entrant = create(:user, email: 'entrant@example.com')
      entry = create(:entry, pool: pool, user: entrant)
      ceremony.categories.each do |category|
        create(:pick, entry: entry, category: category, nominee: category.nominees.detect(&:winner?))
      end

      sign_in_as(create(:user))
      get pool_path(pool)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(new_pool_entry_path(pool))
      expect(response.body).to include('entrant@example.com')
      expect(response.body).to include('2') # score: both picks won
    end

    # CHARACTERIZATION: the page heading is the literal string "Pool" -- it never
    # names the ceremony, even though Pool#award_ceremony_name exists for it.
    # TODO(post-upgrade): show the ceremony name here.
    it 'does not name the award ceremony' do
      ceremony = create(:award_ceremony, name: 'The 90th Academy Awards')
      pool = create(:pool, award_ceremony: ceremony)

      sign_in_as(create(:user))
      get pool_path(pool)

      expect(response.body).not_to include('The 90th Academy Awards')
    end
  end

  describe 'GET /' do
    it 'renders for a signed-out visitor' do
      get '/'
      expect(response).to have_http_status(:ok)
    end

    it 'renders for a signed-in user with no pools' do
      sign_in_as(create(:user))
      get '/'
      expect(response).to have_http_status(:ok)
    end

    it 'sends a user who already has pools straight to their pools' do
      user = create(:user)
      create(:entry, user: user)

      sign_in_as(user)
      get '/'

      expect(response).to redirect_to(pools_path)
    end
  end
end
