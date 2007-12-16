################################################################################
class AddRoles < ActiveRecord::Migration
  
  ################################################################################
  def self.up
    create_table(:roles) do |t|
      t.column(:name,        :string)
      t.column(:description, :string)
    end
    
    add_index(:roles, :name, :unique => true)
    
    create_table(:roles_users, :id => false) do |t|
      t.column(:role_id, :integer)
      t.column(:user_id, :integer)
    end
    
    add_index(:roles_users, :role_id)
    add_index(:roles_users, :user_id)
  end

  ################################################################################
  def self.down
    drop_table(:roles_users)
    drop_table(:roles)
  end
  
end
