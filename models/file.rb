require 'json'
require 'base64'
require 'sequel'

# Holds a full configuration file's information
class SimpleFile < Sequel::Model
  include EncryptableModel
  many_to_one :users
  set_allowed_columns :filename, :description, :file_extension, :remark

  def document=(document_plaintext)
    @document = document_plaintext
    self.document_encrypted = encrypt(@document)
  end

  def document
    @document ||= decrypt(document_encrypted)
  end

  def to_json(options = {})
    doc = document ? Base64.strict_encode64(document) : nil
    JSON({  type: 'file',
            id: id,
            data: {
              file_name: filename,
              description: description,
              file_extension: file_extension,
              remark: remark,
              base64_document: doc
            }
          },
         options)
  end
end
