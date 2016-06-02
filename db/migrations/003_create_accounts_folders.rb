require 'sequel'

Sequel.migration do
  change do
    create_join_table(collaborator_id: :base_accounts, folder_id: :folders)
  end
end
