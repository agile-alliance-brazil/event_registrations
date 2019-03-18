# frozen_string_literal: true

class DeviseMailerPreview < ActionMailer::Preview
  def password_change
    Devise::Mailer.password_change(User.first)
  end

  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(User.first, 'faketoken')
  end

  def unlock_instructions
    Devise::Mailer.unlock_instructions(User.first, 'faketoken')
  end
end
