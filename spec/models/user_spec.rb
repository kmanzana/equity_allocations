describe User do
  describe 'validations' do
    let(:user) do
      User.new username: 'alanwatts', word_press_id: 12
    end

    it 'is valid' do
      expect(user).to be_valid
    end

    it 'validates username presence' do
      user.username = nil
      expect(user).to_not be_valid
    end

    it 'validates word_press_id presence' do
      user.word_press_id = nil
      expect(user).to_not be_valid
    end
  end

  describe 'delegations' do
    describe '#account' do
      it 'returns the account of the investor' do
        user = FactoryGirl.create :user, :with_account
        expect(user.account).to be_an(Account)
      end

      it 'returns nil if no investor or account' do
        expect(User.new.account).to be_nil
      end
    end

    describe '#investor_exists_in_crowd_pay?' do
      it 'returns true if delegated method is true' do
        user = FactoryGirl.create(:investor, :in_crowd_pay).user

        expect(user).to be_investor_exists_in_crowd_pay
      end

      it 'returns nil if no investor' do
        expect(User.new).to_not be_investor_exists_in_crowd_pay
      end
    end

    describe '#account_exists_in_crowd_pay?' do
      it 'returns true if delegated method is true' do
        user = FactoryGirl.create(:account, :in_crowd_pay).user

        expect(user).to be_account_exists_in_crowd_pay
      end

      it 'returns nil if no investor' do
        expect(User.new).to_not be_account_exists_in_crowd_pay
      end
    end
  end

  describe '#authenticated?' do
    it 'returns false for a user with nil digest' do
      user = FactoryGirl.build :user
      expect(user.authenticated?('')).to eq(false)
    end
  end

  describe '#get_or_build_account' do
    it 'returns the account if already exists' do
      user = FactoryGirl.create(:account).user
      expect(user.get_or_build_account).to be_an(Account)
      expect(user.get_or_build_account).to be_persisted
    end

    it 'returns a new account if no account already' do
      user = FactoryGirl.create(:investor).user
      expect(user.get_or_build_account).to be_an(Account)
      expect(user.get_or_build_account).to be_a_new_record
    end

    it 'raises error if no investor' do
      user = FactoryGirl.create :user
      expect { user.get_or_build_account }.to raise_error(Module::DelegationError)
    end
  end
end
