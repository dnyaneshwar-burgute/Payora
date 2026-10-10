require "test_helper"

class InvitationFlowTest < ActionDispatch::IntegrationTest
  setup do
    organizations(:pending).approve!(users(:admin))
    @invitation = Invitation.last
    @token = @invitation.generate_token_for(:acceptance)
  end

  test "the invitation email links to the set password page" do
    mail = InvitationsMailer.invite(@invitation)

    assert_equal [ users(:pending_owner).email_address ], mail.to
    assert_match "Pending Co", mail.subject

    token = mail.text_part.body.to_s[%r{http://pending\.example\.com/invitations/([^/]+)/edit}, 1]
    assert_equal @invitation, Invitation.find_by_token_for(:acceptance, token)
  end

  test "sets the password from the invitation link and signs the user in" do
    host! organizations(:pending).host

    get edit_invitation_path(@token)
    assert_response :success
    assert_select "input[type=password]", count: 2

    patch invitation_path(@token), params: { password: "new-secret-password", password_confirmation: "new-secret-password" }
    assert_redirected_to root_path
    assert cookies[:session_id].present?
    assert @invitation.reload.accepted_at.present?
    assert users(:pending_owner).reload.authenticate("new-secret-password")

    follow_redirect!
    assert_response :success
    assert_select "h1", text: "Pending Co"
  end

  test "the link cannot be reused after acceptance" do
    patch invitation_path(@token), params: { password: "new-secret-password", password_confirmation: "new-secret-password" }

    get edit_invitation_path(@token)
    assert_redirected_to new_session_path
    assert_equal "Invitation link is invalid or has expired.", flash[:alert]
  end

  test "the link expires" do
    travel Invitation::EXPIRES_IN + 1.minute do
      get edit_invitation_path(@token)
      assert_redirected_to new_session_path
    end
  end

  test "requires a password" do
    patch invitation_path(@token), params: { password: "", password_confirmation: "" }

    assert_response :unprocessable_entity
    assert_select ".invalid-feedback", text: /Password can't be blank/
    assert_nil @invitation.reload.accepted_at
  end

  test "requires matching confirmation" do
    patch invitation_path(@token), params: { password: "new-secret-password", password_confirmation: "different" }

    assert_response :unprocessable_entity
    assert_select ".invalid-feedback", text: /Password confirmation doesn't match/
    assert_nil @invitation.reload.accepted_at
  end
end
