class FundAccount
  def self.draft account, investment, ip
    transaction = new account, investment, ip
    transaction.send :create
  end

  private

  attr_reader :account, :investment, :ip, :crowd_pay_transaction

  def initialize account, investment, ip
    @account = account
    @investment = investment
    @ip = ip
  end

  def create
    @crowd_pay_transaction = CrowdPay::Transaction.fund_account fund_account_params
    account.transactions.create transaction_params
  end

  def fund_account_params
    {
      account_id: account.crowd_pay_id,
      amount: investment.amount,
      created_by_ip_address: ip
    }
  end

  def transaction_params
    {
      crowd_pay_id: crowd_pay_transaction.id,
      investment_id: investment.id,
      command: :fund_account,
      amount: investment.amount,
      date: Time.new(crowd_pay_transaction.date)
    }
  end
end
