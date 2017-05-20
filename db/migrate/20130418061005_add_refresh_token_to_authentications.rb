class AddRefreshTokenToAuthentications < ActiveRecord::Migration[4.2]
  def change
    add_column :authentications, :refresh_token, :string
  end
end
