# frozen_string_literal: true

class UserRepository
  include Singleton

  def search_engine(role = nil, text = '')
    user_query = User.where('(first_name LIKE ? OR last_name LIKE ? OR email LIKE ?)', "%#{text}%", "%#{text}%", "%#{text}%").order(updated_at: :desc)
    user_query = user_query.where(role: role) if role.present?

    user_query
  end
end
