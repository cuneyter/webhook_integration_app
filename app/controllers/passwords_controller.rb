class PasswordsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  before_action :set_user_by_token, only: %i[ edit update ]

  def new
  end

  def create
    if password_params[:email_address].present?
      normalised_email = password_params[:email_address].strip.downcase
      if (user = User.find_by(email_address: normalised_email))
        PasswordsMailer.reset(user).deliver_later
      end
    end

    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to new_session_path, notice: "Password has been reset."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.permit(:email_address)
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
  end
end
