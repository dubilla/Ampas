require 'rails_helper'

# The only specs that run JavaScript: they cover what Turbo handles in the
# browser (form submissions, data-turbo-method links) and request specs can't.
RSpec.describe 'Turbo navigation', type: :system do
  let(:ceremony) { create(:award_ceremony, :with_categories, category_count: 1, nominee_count: 2) }
  let(:pool) { create(:pool, award_ceremony: ceremony) }
  let(:user) { create(:user) }
  let(:category) { ceremony.categories.first }
  let!(:entry) do
    create(:entry, pool: pool, user: user).tap do |e|
      create(:pick, entry: e, category: category, nominee: category.nominees.first)
    end
  end

  def sign_in(as: user, password: 'password')
    visit new_user_session_path
    fill_in 'Email', with: as.email
    fill_in 'Password', with: password
    click_button 'Log in'
  end

  it 'signs in, edits an entry and logs out' do
    sign_in
    expect(page).to have_link('Logout')

    click_link 'View Pool'
    click_link href: entry_path(entry)
    click_link 'Edit Entry'
    choose category.nominees.second.name
    click_button 'Submit'

    expect(page).to have_current_path(entry_path(entry))
    expect(page).to have_css('td', text: category.nominees.second.name)

    click_link 'Logout'
    expect(page).to have_link('Log in')
    expect(page).to have_no_link('Logout')
  end

  # Uses a user without entries: destroying one with entries raises
  # ActiveRecord::InvalidForeignKey today (User has no dependent: on entries).
  it 'asks for confirmation before cancelling an account' do
    loner = create(:user)
    sign_in(as: loner)
    expect(page).to have_link('Logout')
    visit edit_user_registration_path

    dismiss_confirm('Are you sure?') { click_button 'Cancel my account' }
    expect(User.exists?(loner.id)).to be(true)

    accept_confirm('Are you sure?') { click_button 'Cancel my account' }
    expect(page).to have_link('Log in')
    expect(User.exists?(loner.id)).to be(false)
  end

  it 're-renders the sign-in form after a failed sign-in' do
    sign_in(password: 'wrong')

    expect(page).to have_content('Invalid email or password.')
    expect(page).to have_field('Email')
  end
end
