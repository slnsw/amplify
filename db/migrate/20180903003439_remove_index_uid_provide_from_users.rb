# frozen_string_literal: true

class RemoveIndexUidProvideFromUsers < ActiveRecord::Migration[5.2]
  def change
    # removing this uniqe to work with email logins
    remove_index :users, column: %i[uid provider]
  end
end
