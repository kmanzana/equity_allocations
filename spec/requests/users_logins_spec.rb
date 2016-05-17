require 'rails_helper'

describe 'UsersLogins', type: :request do
  let(:user) { FactoryGirl.create :user }

  context 'with invalid login information' do
    before do
      stub_request(:post, 'https://equityallocations.com/oauth/token')
      .to_return status: 401, body: { error_description: 'test_error' }.to_json
    end

    it 'renders new and displays flash' do
      get login_path
      expect(response).to render_template('sessions/new')
      post login_path, session: { username: '', password: '' }
      expect(response).to render_template('sessions/new')
      expect(flash).to_not be_empty
      get root_path
      expect(flash).to be_empty
    end
  end

  context 'with valid login information' do
    include Capybara::DSL

    before do
      stub_request(:post, 'https://equityallocations.com/oauth/token')
      .to_return status: 200, body: {
        access_token: 'myaccesstoken',
        expires_in: 3600,
        token_type: 'Bearer',
        scope: 'basic',
        refresh_token: 'myrefreshtoken'
      }.to_json

      stub_request(:get, 'https://equityallocations.com/wp-json/wp/v2/users/me')
      .with(query: {
        _envelope: '',
        access_token: 'myaccesstoken',
        context: 'edit'
      })
      .to_return status: 200, body: { body: { id: user.word_press_id } }.to_json
    end

    it 'logs the user in and redirects to show page' do
      visit login_path
      fill_in :Username, with: user.username
      fill_in :Password, with: 'password'
      find('input[@value="Log in"]').click
      expect(page.current_path).to eql(user_path(user))
      expect(page).to_not have_link('Log in', href: login_path)
      expect(page).to have_link('Log out', href: logout_path)
      expect(page).to have_link('Profile', href: user_path(user))
    end

    context 'login with remembering' do
      it 'sets the remember_token in cookies' do
        log_in_as user, remember_me: '1'
        expect(cookies['remember_token']).to_not be_nil
      end
    end

    context 'login without remembering' do
      it 'does not set the remember_token in cookies' do
        log_in_as user, remember_me: '0'
        expect(cookies['remember_token']).to be_nil
      end
    end
  end
end
