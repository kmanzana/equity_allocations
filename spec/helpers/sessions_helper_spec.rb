describe SessionsHelper, type: :helper do
  let(:user) { FactoryGirl.create :user }

  before do
    remember user
  end

  describe '#current_user' do
    it 'returns correct user when session is nil' do
      expect(user).to eql(current_user)
    end

    it 'returns nil when remember digest is wrong' do
      user.update_attribute :remember_digest, User.digest(User.new_token)
      expect(current_user).to be_nil
    end
  end
end
