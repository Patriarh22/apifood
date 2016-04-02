class AddTelegramChatIdToUsers < ActiveRecord::Migration
  def change
    drop_table :users
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :oauth_token
      t.string :tele_chat_id
      t.datetime :oauth_expires_at

      t.timestamps null: false
    end
  end
end

