class InvitationsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access
  before_action :set_invitation
  rate_limit to: 10, within: 3.minutes, only: :update, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def edit
  end

  def update
    if @invitation.accept(password: params[:password], password_confirmation: params[:password_confirmation])
      start_new_session_for @invitation.user
      redirect_to root_path, notice: "Your password has been set. Welcome to #{@invitation.user.organization.name}!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_invitation
      @invitation = Invitation.find_by_token_for(:acceptance, params[:token])
      redirect_to new_session_path, alert: "Invitation link is invalid or has expired." unless @invitation
    end
end
