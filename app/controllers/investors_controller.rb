class InvestorsController < ApplicationController
  before_action :check_investor_existence

  def personal_info
    @investor = current_user.investor
  end

  def create
    integrator = InvestorIntegrator.new current_user.investor, investor_params,
                                        request.remote_ip

    integrator.verify_and_create_external_investor

    if integrator.success?
      redirect_to billing_info_path
    else
      # setting @investor to show errors when personal info is rendered
      @investor = current_user.investor
      flash.now[:danger] = integrator.error
      render :personal_info
    end
  end

  private

  def investor_params
    params.require(:investor)
    .permit :first_name, :middle_name, :last_name, :address1, :address2, :city,
            :state, :zip, :email, :tax_id, :birth_date, :foreign_address
  end

  def check_investor_existence
    if current_user.investor_exists_in_crowd_pay?
      redirect_to billing_info_path
    end
  end
end
