# frozen_string_literal: true

class CreateOrcidIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :orcid_identities do |t|
      t.belongs_to :user
      t.string :name
      t.string :orcid_id, index: true
      t.string :access_token, index: true
      t.string :token_type
      t.string :refresh_token
      t.integer :expires_in
      t.string :scope
      t.integer :work_sync_preference, default: 0
      t.index :work_sync_preference
      t.column :profile_sync_preference, :json, default: {}

      t.timestamps
    end
  end
end
