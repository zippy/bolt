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
class Role < ActiveRecord::Base

  ################################################################################
  validates_presence_of(:name)
  validates_uniqueness_of(:name)

  ################################################################################
  has_many(:allowances) do
    ################################################################################
    # Add permissions to this role, based on their names, for example:
    #
    #  @role.allowances.add(:edit_articles) # default allowance of 1
    #  @role.allowances.add(:post_articles, 5) # set allowance to 5
    def add (name, allowance=1)
      permission = Permission.find_by_name(name.to_s)
      raise "permission does not exist '#{name}'" if permission.nil?
      create(:permission_id => permission.id, :allowance => allowance)
    end

    ################################################################################
    # Remove permissions from this role, based on their names, for example:
    #
    #  @role.allowances.remove(:edit_articles, :post_articles)
    def remove (*perms)
      perms = perms.map(&:to_s)
      delete(*proxy_target.select{|a|perms.include?(a.permission.name)})
    end

    ################################################################################
    # Remove all permissions, and then add back the given permissions.  This
    # is useful for calling from a controller that is processing the contents
    # of an HTML form.
    #
    # Example:
    #
    #  @role.allowances.reset!(:edit_articles => 1, :post_articles => 5)
    #  @role.allowances.reset!(:edit_articles, :post_articles)
    def reset! (*perms)
      if perms.size == 1 and perms.first.respond_to?(:keys)
        perms = perms.first
      elsif perms.size == 0
        perms = {}
      else
        perms = Hash[*perms.map{|p|[p,1]}.flatten]
      end

      Role.transaction do
        proxy_owner.allowances.clear
        perms.each do |name, allowance| 
          next if allowance.blank?
          proxy_owner.allowances.add(name.to_s, allowance.to_i)
        end
      end
    end
  end

  ################################################################################
  has_many(:permissions, :through => :allowances)

  ################################################################################
  # Lookup the given permission by name, and if it belongs to this role return
  # the matching allowance.  Otherwise, returns nil.
  def authorize (permission_name)
    self.allowances.detect {|a| a.permission.name == permission_name.to_s}
  end

  ################################################################################
  # Returns true if this role has all the given permissions.
  def can? (*perms)
    perms.each {|p| return false if authorize(p).nil?}
    return true
  end

end
