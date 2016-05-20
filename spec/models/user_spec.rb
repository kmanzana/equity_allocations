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

  describe '#authenticated?' do
    it 'returns false for a user with nil digest' do
      user = FactoryGirl.build :user
      expect(user.authenticated?('')).to eq(false)
    end
  end
end
