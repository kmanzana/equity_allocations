describe SingleSignOn do
  describe '.authenticate' do
    let(:credentials) { { username: 'username', password: 'password' } }

    it 'authenticates using credentials with WordPress' do
      expect(WordPress).to receive(:authenticate)
      .with(credentials)
      .and_return WordPress.new(error: 'test_error')

      SingleSignOn.authenticate credentials
    end

    it 'returns false if authentication errors' do
      allow(WordPress).to receive(:authenticate)
      .and_return WordPress.new(error: 'test_error')

      user = SingleSignOn.authenticate credentials
      expect(user).to be_falsey
    end

    context 'user already exists' do
      it 'returns user found by word_press_id' do
        mock_client = double
        mock_client.stub(:current_user).and_return 'id' => 21
        mock_client.stub(:error?).and_return false

        existing_user = FactoryGirl.create :user, word_press_id: 21

        allow(WordPress).to receive(:authenticate).and_return mock_client

        user = SingleSignOn.authenticate credentials

        expect(user).to eq(existing_user)
      end

      # not necessary?
      # it 'updates any changed attributes'
    end

    context 'user does not exist' do
      let(:mock_client) do
        client = double
        client.stub(:error?).and_return false
        client.stub(:current_user).and_return(
          'id' => 14,
          'first_name' => 'Foo',
          'last_name' => 'Bar',
          'email' => 'foo@bar.com'
        )
        client
      end

      before do
        allow(WordPress).to receive(:authenticate).and_return mock_client
      end

      it 'creates new user' do
        expect { SingleSignOn.authenticate credentials }
        .to change(User, :count).by(1)
      end

      it 'uses username for new user params' do
        user = SingleSignOn.authenticate credentials
        expect(user.username).to eq(credentials[:username])
      end

      it 'maps word_press data to new investor params' do
        user = SingleSignOn.authenticate credentials

        expect(investor.first_name).to eq(mock_client.current_user['first_name'])
        expect(investor.last_name).to eq(mock_client.current_user['last_name'])
        expect(investor.email).to eq(mock_client.current_user['email'])
      end

      it 'maps id to word_press_id' do
        user = SingleSignOn.authenticate credentials
        expect(user.word_press_id).to eq(mock_client.current_user['id'])
      end

      it 'returns new user' do
        user = SingleSignOn.authenticate credentials
        expect(user).to eq(User.last)
      end

      it 'raises error if user creation validation fails' do
        mock_client.stub(:current_user).and_return 'id' => 2

        expect { SingleSignOn.authenticate credentials }
        .to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
end
