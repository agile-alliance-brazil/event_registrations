class AddRefreshTokenToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :refresh_token, :string
  end
end
