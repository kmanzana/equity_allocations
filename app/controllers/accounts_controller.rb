class AccountsController < ApplicationController
  before_action :check_investor_and_account_existence

  def new
    @account = current_user.get_or_build_account
  end

  def create
    # setting @investor to show errors when billing_info is rendered
    @account = current_user.get_or_build_account

    integrator = AccountIntegrator.new @account, account_params,
                                       request.remote_ip

    integrator.create_external_account

    if integrator.success?
      redirect_to new_investment_path(amount: params[:amount])
    else
      flash.now[:danger] = integrator.error
      render :billing_info
    end
  end

  private

  def check_investor_and_account_existence
    if current_user.account_exists_in_crowd_pay?
      redirect_to new_investment_path(amount: params[:amount])
    elsif !current_user.investor_exists_in_crowd_pay?
      redirect_to new_investor_path(amount: params[:amount])
    end
  end

  def account_params
    params.require(:account)
    .permit :account_name, :routing_number, :account_number, :savings_account
  end
end
