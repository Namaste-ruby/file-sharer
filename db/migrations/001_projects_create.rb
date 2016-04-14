require 'sequel'

Sequel.migration do
  change do
    create_table(:projects) do
      primary_key :id
      String :file_extension
      String :description
      String :remark
    end
  end
end
