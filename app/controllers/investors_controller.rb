class InvestorsController < ApplicationController
  def personal_info
    @investor = current_user.investor

    redirect_to(billing_info_path) if @investor.investor_id
  end

  def create
    @investor = current_user.investor # setting @investor to show errors when personal info is rendered

    integrator = InvestorIntegrator.new @investor, investor_params, request.remote_ip
    integrator.verify_and_create_external_investor

    if integrator.success?
      redirect_to billing_info_path
    else
      flash.now[:danger] = integrator.error #
      render :personal_info
    end
  end

  private

  def investor_params
    params.require(:investor)
    .permit :first_name, :middle_name, :last_name, :address1, :address2, :city,
            :state, :zip, :email, :tax_id, :birth_date, :foreign_address
  end
end
