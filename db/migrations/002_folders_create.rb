require 'sequel'

Sequel.migration do
  change do
    create_table(:folders) do
      primary_key :id
      foreign_key :owner_id, :base_accounts
      String :name, null: false
      String :folder_url_encrypted, unique: true
      DateTime :created_at
      DateTime :updated_at

      unique [:owner_id, :name]
    end
  end
end
