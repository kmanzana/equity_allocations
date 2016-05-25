class AccountsController < ApplicationController
  before_action :check_investor_and_account_existence

  def billing_info
    @account = current_user.get_or_build_account
  end

  def create
    # setting @investor to show errors when billing_info is rendered
    @account = current_user.get_or_build_account

    integrator = AccountIntegrator.new @account, account_params,
                                       request.remote_ip

    integrator.create_external_account

    if integrator.success?
      redirect_to confirm_path
    else
      flash.now[:danger] = integrator.error
      render :billing_info
    end
  end

  private

  def check_investor_and_account_existence
    if current_user.account_exists_in_crowd_pay?
      return redirect_to confirm_path
    end

    unless current_user.investor_exists_in_crowd_pay?
      redirect_to personal_info_path
    end
  end

  def account_params
    params.require(:account)
    .permit :account_name, :routing_number, :account_number, :savings_account
  end
end
