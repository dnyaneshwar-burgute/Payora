class RegistrationsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    @organization = Organization.new
    @organization.users.build
  end

  def create
    registration = OrganizationRegistrationService.new(organization_params)
    @organization = registration.organization

    if registration.call
      start_new_session_for registration.owner
      redirect_to root_path, notice: "Welcome! #{@organization.name} has been registered."
    else
      @organization.users.build if @organization.users.empty?
      render :new, status: :unprocessable_entity
    end
  end

  private
    def organization_params
      params.expect(organization: [ :name, :host, users_attributes: [ [ :first_name, :last_name, :email_address, :phone_number ] ] ])
    end
end
