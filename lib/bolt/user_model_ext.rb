################################################################################
#
# Copyright (C) 2006-2007 pmade inc. (Peter Jones pjones@pmade.com)
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
module Bolt
  
  ################################################################################
  # Extensions to the user model to allow for authentication and
  # authorization.  You can control which of your ActiveRecord models
  # is considered to be the user model by setting the user_model
  # option in the Bolt::Config class.
  module UserModelExt
    
    ################################################################################
    # This method is called when this module is included into the user model.
    def self.included (klass)
      # Do a safety check, make sure the users table has the correct foreign key
      if klass.table_exists? and !klass.columns.map(&:name).include?('bolt_identity_id')
        raise "#{klass} is missing the bolt_identity_id column" 
      end

      # Additional validations that need to be added to the user model
      klass.validate do |record|
        # Transfer errors from the Bolt::Identity model to the record
        if account = record.instance_variable_get(:@bolt_identity)
          account.errors.full_messages.each {|m| record.errors.add_to_base(m)}
        end
      end
      
      klass.has_and_belongs_to_many(:roles)
      klass.has_many(:allowances,  :through => :role)
      klass.has_many(:permissions, :through => :allowances)
    end

    ################################################################################
    # Lookup the given permission by name, and if it belongs to this
    # user through a role, return the matching allowance.  Otherwise,
    # returns nil.
    def authorize (permission_name)
      roles.detect {|r| r.authorize(permission_name)}
    end

    ################################################################################
    # Returns true if the user has all the given permissions.
    def can? (*perms)
      perms.each {|p| return false unless roles.detect {|r| r.can?(p)}}
      true
    end

  end
end
