# frozen_string_literal: true

class UserRepository
  include Singleton

  def search_engine(role = nil, text = '')
    user_query = User.where('(first_name ILIKE :search_text OR last_name ILIKE :search_text OR email ILIKE :search_text)', search_text: "%#{text}%").order(updated_at: :desc)
    user_query = user_query.where(role: role) if role.present?

    user_query
  end
end
