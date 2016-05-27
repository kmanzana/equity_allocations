class InvestorsController < ApplicationController
  before_action :check_investor_existence

  def new
    @investor = current_user.investor
  end

  def create
    integrator = InvestorIntegrator.new current_user.investor, investor_params,
                                        request.remote_ip

    integrator.verify_and_create_external_investor

    if integrator.success?
      redirect_to new_account_path(amount: params[:amount])
    else
      # setting @investor to show errors when personal info is rendered
      @investor = current_user.investor
      flash.now[:danger] = integrator.error
      render :new
    end
  end

  private

  def investor_params
    params.require(:investor)
    .permit :first_name, :middle_name, :last_name, :address1, :address2, :city,
            :state, :zip, :email, :tax_id, :birth_date, :foreign_address,
            :terms, :annual_income, :net_worth
  end

  def check_investor_existence
    if current_user.investor_exists_in_crowd_pay?
      redirect_to new_account_path(amount: params[:amount])
    end
  end
end
