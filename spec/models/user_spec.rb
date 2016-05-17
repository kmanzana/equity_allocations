describe User do
  describe 'validations' do
    let(:user) do
      User.new first_name: 'Example', last_name: 'User',
               email: 'user@example.com', username: 'exampleuser'

    end

    it 'is valid' do
      expect(user).to be_valid
    end

    it 'validates first_name presence' do
      user.first_name = ''
      expect(user).to_not be_valid
    end

    it 'validates last_name presence' do
      user.last_name = ''
      expect(user).to_not be_valid
    end

    it 'validates email presence' do
      user.email = '      '
      expect(user).to_not be_valid
    end

    it 'validates first_name length' do
      user.first_name = 'a' * 51
      expect(user).to_not be_valid
    end

    it 'validates last_name length' do
      user.last_name = 'a' * 51
      expect(user).to_not be_valid
    end

    it 'validates email length' do
      user.email = 'a' * 39 + '@example.com'
      expect(user).to_not be_valid
    end

    it 'allows valid email addresses' do
      valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                           first.last@foo.jp alice+bob@baz.cn]

      valid_addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid, "expect #{valid_address.inspect} to be valid"
      end
    end

    it 'rejects invalid email addresses' do
      invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                             foo@bar_baz.com foo@bar+baz.com foo@bar..com]

      invalid_addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).to_not be_valid, "expect #{invalid_address.inspect} to be invalid"
      end
    end

    it 'validates email uniqueness' do
      duplicate_user = user.dup
      duplicate_user.email = user.email.upcase
      user.save

      expect(duplicate_user).to_not be_valid
    end

    it 'downcases emails' do
      mixed_case_email = "Foo@ExAMPle.CoM"
      user.email = mixed_case_email
      user.save
      expect(mixed_case_email.downcase).to eq(user.reload.email)
    end
  end

  describe '#authenticated?' do
    it 'returns false for a user with nil digest' do
      user = FactoryGirl.build :user
      expect(user.authenticated?('')).to eq(false)
    end
  end
end
