class AddUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :organization
      t.string :phone
      t.string :country
      t.string :state
      t.string :city

      t.string :badge_name
      t.string :cpf
      t.string :gender
      t.string :twitter_user
      t.string :address
      t.string :neighbourhood
      t.string :zipcode

      t.integer :roles_mask

      t.string :default_locale, default: 'pt'

      t.timestamps
    end

    create_table :authentications do |t|
      t.references :user
      t.string :provider
      t.string :uid

      t.timestamps
    end
  end
end
