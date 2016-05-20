describe Investor do
  describe 'validations' do
    let(:investor) do
      Investor.new first_name: 'Alan', last_name: 'Watts', middle_name: 'James',
                   email: 'alan@watts.com', tax_id: 123456789, person: true,
                   address1: '1234 Some St', city: 'Somewhere', state: 'IL',
                   zip: '12345', birth_date: 30.years.ago
    end

    it 'is valid' do
      expect(investor).to be_valid
    end

    it 'validates first_name presence' do
      investor.first_name = ''
      expect(investor).to_not be_valid
    end

    it 'validates last_name presence' do
      investor.last_name = ''
      expect(investor).to_not be_valid
    end

    it 'validates organization_name absence' do
      investor.organization_name = 'Some Org'
      expect(investor).to_not be_valid
    end

    it 'validates email presence' do
      investor.email = '      '
      expect(investor).to_not be_valid
    end

    it 'validates tax_id presence' do
      investor.tax_id = nil
      expect(investor).to_not be_valid
    end

    it 'validates first_name length' do
      investor.first_name = 'a' * 51
      expect(investor).to_not be_valid
    end

    it 'validates last_name length' do
      investor.last_name = 'a' * 51
      expect(investor).to_not be_valid
    end

    it 'validates email length' do
      investor.email = 'a' * 39 + '@example.com'
      expect(investor).to_not be_valid
    end

    it 'allows valid email addresses' do
      valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                           first.last@foo.jp alice+bob@baz.cn]

      valid_addresses.each do |valid_address|
        investor.email = valid_address
        expect(investor).to be_valid, "expect #{valid_address.inspect} to be valid"
      end
    end

    it 'rejects invalid email addresses' do
      invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                             foo@bar_baz.com foo@bar+baz.com foo@bar..com]

      invalid_addresses.each do |invalid_address|
        investor.email = invalid_address
        expect(investor).to_not be_valid, "expect #{invalid_address.inspect} to be invalid"
      end
    end

    it 'validates email uniqueness' do
      duplicate_investor = investor.dup
      duplicate_investor.email = investor.email.upcase
      investor.save

      expect(duplicate_investor).to_not be_valid
    end

    it 'downcases emails' do
      mixed_case_email = "Foo@ExAMPle.CoM"
      investor.email = mixed_case_email
      investor.save
      expect(mixed_case_email.downcase).to eq(investor.reload.email)
    end

    it 'allows valid tax ids' do
      valid_tax_ids = [512122291, 990001312]

      valid_tax_ids.each do |valid_tax_id|
        investor.tax_id = valid_tax_id
        expect(investor).to be_valid, "expect #{valid_tax_id.inspect} to be valid"
      end
    end

    it 'rejects invalid tax ids' do
      invalid_tax_ids = [0, 12345678, 1234567890, 9380823090]

      invalid_tax_ids.each do |invalid_tax_id|
        investor.tax_id = invalid_tax_id
        expect(investor).to_not be_valid, "expect #{invalid_tax_id.inspect} to be invalid"
      end
    end

    context 'when investor is an organization' do
      let(:organization_investor) do
        Investor.new organization_name: 'Some Org', email: 'some@org.com',
                     tax_id: 123456789, person: false,
                     address1: '1234 Some St', city: 'Somewhere', state: 'IL',
                     zip: '12345', birth_date: 40.years.ago
      end

      it 'is valid' do
        expect(organization_investor).to be_valid
      end

      it 'validates organization_name presence' do
        organization_investor.organization_name = ''
        expect(organization_investor).to_not be_valid
      end

      it 'validates first_name absence' do
        organization_investor.first_name = 'name'
        expect(organization_investor).to_not be_valid
      end
    end
  end
end
