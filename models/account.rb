require 'json'
require 'sequel'

# Holds a User's information
class User < Sequel::Model
  include SecureModel

  plugin :timestamps, update_on_create: true
  # plugin :association_dependencies, :simple_files => :delete
  set_allowed_columns :group_name

  one_to_many :simple_files
  many_to_one :owner, class: :User
  many_to_many :group_members,
               class: :User, join_table: :groups_users,
               left_key: :user_id, right_key: :group_member_id

plugin :association_dependencies, simple_files: :destroy

  def before_destroy
    DB[:groups_users].where(user_id: id).delete
    super
  end

  def repo_url
    decrypt(repo_url_encrypted)
  end

  def repo_url=(repo_url_plaintext)
    self.repo_url_encrypted = encrypt(repo_url_plaintext) if repo_url_plaintext
  end


  def to_json(options = {})
    JSON({  type: 'group',
            id: id,
            attributes: {
              username: groupname,
              description: description
            }
          },
         options)
  end
end
