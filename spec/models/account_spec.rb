describe Account do
  describe 'validations' do
    let(:investor) { FactoryGirl.create :investor }

    let(:account) do
      Account.new investor: investor, routing_number: 987654321,
                  account_number: 1234567890, account_name: 'Edward Abbey'
    end

    it 'is valid' do
      expect(account).to be_valid
    end

    it 'validates investor_id presence' do
      account.investor_id = nil
      expect(account).to_not be_valid
    end

    it 'validates routing_number presence' do
      account.routing_number = nil
      expect(account).to_not be_valid
    end

    it 'validates account_number presence' do
      account.account_number = nil
      expect(account).to_not be_valid
    end

    it 'validates account_name presence' do
      account.account_name = '  '
      expect(account).to_not be_valid
    end

    it 'validates routing_number length' do
      account.routing_number = ('1' * 10).to_i
      expect(account).to_not be_valid
    end

    it 'validates account_number length' do
      account.account_number = ('1' * 18).to_i
      expect(account).to_not be_valid
    end

    it 'validates account_name length' do
      account.account_name = 'a' * 51
      expect(account).to_not be_valid
    end
  end

  describe '#exists_in_crowd_pay?' do
    it 'returns true if crowd_pay_id is already set' do
      account = FactoryGirl.build :account, :in_crowd_pay
      expect(account).to be_exists_in_crowd_pay
    end

    it 'returns false if no crowd_pay_id' do
      account = FactoryGirl.build :account
      expect(account).to_not be_exists_in_crowd_pay
    end
  end
end
