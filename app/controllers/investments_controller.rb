class InvestmentsController < ApplicationController
  before_action :check_investor_and_account_existence

  def amount
    @amount = 0
  end

  def new
    @investment = Investment.new amount: params[:amount]
  end

  def create
    investment = current_user.build_investment investment_params

    if investment.save
      FundAccount.draft current_user.account, investment, request.remote_ip
      redirect_to investment
    else
      render plain: "Something went wrong\n#{investment.errors.messages}"
    end
  end

  def show
    @investment = Investment.find params[:id]
  end

  private

  def check_investor_and_account_existence
    if !current_user.investor_exists_in_crowd_pay?
      redirect_to new_investor_path(amount: params[:amount])
    elsif !current_user.account_exists_in_crowd_pay?
      redirect_to new_account_path(amount: params[:amount])
    end
  end

  def investment_params
    params.require(:investment)
    .permit :amount
  end
end
