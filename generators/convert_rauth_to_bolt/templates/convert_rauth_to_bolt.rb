################################################################################
#
# Copyright (C) 2006-2008 pmade inc. (Peter Jones pjones@pmade.com)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################
class ConvertRauthToBolt < ActiveRecord::Migration

  ################################################################################
  class User < ActiveRecord::Base; end

  ################################################################################
  def self.bolt_version= (v)
    execute("delete from plugin_schema_info where plugin_name = 'bolt'");
    execute("insert into plugin_schema_info (plugin_name, version) values ('bolt', #{v})")
  end

  ################################################################################
  def self.up
    rename_table(:rauth_native_accounts, :identities)
    add_column(:identities, :updated_at, :datetime)
    rename_column(:users, :account_id, :bolt_identity_id)

    create_table(:roles_users, :id => false) do |t|
      t.column(:role_id, :integer)
      t.column(:user_id, :integer)
    end
    
    add_index(:roles_users, :role_id)
    add_index(:roles_users, :user_id)

    if User.column_names.include?('role_id')
      execute("insert into roles_users (role_id, user_id) (select role_id, id from users)")
      remove_column(:users, :role_id)
    end

    self.bolt_version = 4
  end

  ################################################################################
  def self.down
    rename_column(:users, :bolt_identity_id, :account_id)
    remove_column(:identities, :updated_at)
    rename_table(:identities, :rauth_native_accounts)
    add_column(:users, :role_id, :integer)
    # FIXME revert role_id
    drop_table(:roles_users)
    self.bolt_version = 0
  end
end
