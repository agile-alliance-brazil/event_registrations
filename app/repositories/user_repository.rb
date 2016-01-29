class UserRepository
  include Singleton

  def search_engine(text = '')
    User.where('(first_name LIKE ? OR last_name LIKE ? OR email LIKE ?)', "%#{text}%", "%#{text}%", "%#{text}%").order(updated_at: :desc)
  end
end
