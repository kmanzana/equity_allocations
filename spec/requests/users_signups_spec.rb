describe 'UsersSignups', type: :request do
  it 'handles invalid signup information' do
    get signup_path

    expect {
      post users_path, user: { name:  '',
                               email: 'user@invalid',
                               password:              'foo',
                               password_confirmation: 'bar' }
    }.to_not change(User, :count)

    expect(response).to render_template('users/new')
  end

  it 'handles valid signup information' do
    get signup_path

    expect {
      post_via_redirect users_path, user: { name:  'Example User',
                                            email: 'user@example.com',
                                            password:              'password',
                                            password_confirmation: 'password' }
    }.to change(User, :count).by(1)

    expect(response).to render_template('users/show')
  end
end
