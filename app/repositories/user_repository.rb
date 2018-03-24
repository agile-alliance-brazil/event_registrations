# frozen_string_literal: true

class UserRepository
  include Singleton

  def search_engine(roles_mask, text = '')
    user_query = User.where('(first_name LIKE ? OR last_name LIKE ? OR email LIKE ?)', "%#{text}%", "%#{text}%", "%#{text}%").order(updated_at: :desc)
    if roles_mask.present? && roles_mask.to_i >= 0
      user_query = user_query.where(roles_mask: roles_mask.to_i)
    end
    user_query
  end
end
