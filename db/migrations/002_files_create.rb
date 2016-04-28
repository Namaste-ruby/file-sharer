require 'sequel'

Sequel.migration do
  change do
    create_table(:simple_files) do
      primary_key :id
      foreign_key :user_id

      String :filename, null: false
      String :description
      String :document_encrypted, text: true
      String :file_extension, null: false, default: ''
      String :remark, null: false, default: 'None'

    end
  end
end
