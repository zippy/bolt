################################################################################
class AddAllowances < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table(:allowances) do |t|
      t.column(:role_id,       :integer)
      t.column(:permission_id, :integer)
      t.column(:allowance,     :integer, :default => 1)
    end

    add_index(:allowances, :role_id)
  end

  ################################################################################
  def self.down
    drop_table(:allowances)
  end

end
