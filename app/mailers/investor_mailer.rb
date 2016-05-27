class InvestorMailer < ApplicationMailer
  default from: 'info@equityallocations.com'

  def welcome_email(investor)
    @investor = investor
    mail(to: @investor.email, subject: 'Welcome to Equity Allocations Crowdfunding Portal')
  end
end
