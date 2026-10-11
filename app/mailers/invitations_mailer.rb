class InvitationsMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @user = invitation.user
    @organization = @user.organization
    @token = invitation.generate_token_for(:acceptance)

    mail subject: "You're invited to #{@organization.name}", to: @user.email_address
  end
end
