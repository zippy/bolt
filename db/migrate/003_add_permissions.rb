################################################################################
class AddPermissions < ActiveRecord::Migration

  ################################################################################
  def self.up
    create_table(:permissions) do |t|
      t.column(:name,        :string)
      t.column(:description, :string)
    end

    add_index(:permissions, :name, :unique => true)
  end
  
  ################################################################################
  def self.down
    drop_table(:permissions)
  end
  
end
