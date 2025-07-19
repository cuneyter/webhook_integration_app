# Preview all emails at http://localhost:3000/rails/mailers/passwords_mailer
class PasswordsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/passwords_mailer/reset
  def reset
    user = User.first
    unless user
      user = User.create!(
        email_address: "test@example.com",
        password: "password",
        password_confirmation: "password")
    end
    PasswordsMailer.reset(user)
  end
end
