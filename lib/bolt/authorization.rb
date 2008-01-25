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
module Bolt
  
  ################################################################################
  # Authorization is when you check to see if the current user has
  # permission to perform an action.  Bolt provides two ways to
  # perform authorization.  The first is by using a controller before
  # filter, the second is by querying the user model directly.
  #
  # Before you being using the authorization services of Bolt, you'll
  # want to create some user roles.  I usually make use of migrations
  # to create the initial set of roles and permissions.
  #
  #  Permission.create!(:name => 'edit_blogs')
  #  Permission.create!(:name => 'add_users')
  #
  #  admin_role = Role.create!(:name => 'System Administrator')
  #  admin_role.allowances.add('edit_blogs')
  #  admin_role.allowances.add('add_users')
  #
  #  some_user_object.roles << admin_role
  #  some_user_object.can?(:add_users) # => true
  #
  # You can have your controller perform authorization by using the
  # +require_authorization+ class method.
  #
  # For further information about authorization, see the following:
  # * Bolt::UserModelExt (for helper methods like +can?+)
  # * Role (the role model)
  # * Permission (the permission model)
  # * Allowance (the allowance model)
  # * Bolt::Authorization::ClassMethods (for the +require_authorization+ method)
  module Authorization
    
    ################################################################################
    def self.included (klass) #:nodoc:
      klass.send(:extend,  Bolt::Authorization::ClassMethods)
      klass.send(:include, Bolt::Authorization::InstanceMethods)
    end
    
    ################################################################################
    # Methods added to all controllers as class methods.
    module ClassMethods
      ################################################################################
      # Require that the current user have the given permissions.  This
      # call sets a before_filter that will first authenticate the user
      # (if necessary) and then checks the current users permissions.
      #
      # Examples:
      #
      #  require_authorization(:admin)
      #
      #  require_authorization(:create_users, :delete_users, :only => [:create, :destroy])
      def require_authorization (*permissions)
        options = permissions.last.is_a?(Hash) ? permissions.pop : {}
        before_filter(options) {|c| c.instance_eval {authorize(*permissions)}}
      end
    end
    
    ################################################################################
    # Methods added to all controllers as instance methods
    module InstanceMethods
      ################################################################################
      # Ensure that the current user has the given permissions.  Permissions
      # is a list of permission names that the current user must have.  The
      # last argument can be a hash with the following keys:
      #
      # <tt>:or_user_matches</tt>:: If set to a User object, return true if that user is the current user.
      # <tt>:condition</tt>:: Returns true if this key is the true value
      #
      # So, why call this method and use one of the options above?  Because
      # this method forces authentication and may be useful when called from
      # a controller action.
      #
      # There are two special instance methods that your controller can
      # implement as callbacks:
      #
      # +unauthorized+:: 
      # Called when authorization failed.  You can do
      # whatever you like here, redirect, render something, set a flash
      # message, it's up to you. If you don't supply this method, an
      # automatic redirection will happen.
      #
      # +check_allowance+:: 
      # If you supply this method, the user and
      # allowance will be passed to it.  You should explicitly return
      # false if the user isn't authroized to continue.
      ################################################################################
      def authorize (*permissions)
        return false unless user = authenticate

        configuration = {
          :or_user_matches => nil,
          :condition       => :pill,
        }

        configuration.update(permissions.last.is_a?(Hash) ? permissions.pop : {})
        return true if !configuration[:or_user_matches].nil? and user == configuration[:or_user_matches]
        return configuration[:condition] unless configuration[:condition] == :pill

        permissions.each do |name|
          if allowance = user.authorize(name) and respond_to?(:check_allowance)
            allowance = nil if check_allowance(user, allowance) == false
          end

          return bolt_failed_authorization if allowance.nil?
        end

        true
      end

      ################################################################################
      # Helper method called when authorization fails
      def bolt_failed_authorization #:nodoc:
        unauthorized if respond_to?(:unauthorized)

        if !performed?
          redirect_to(request.env["HTTP_REFERER"] ? :back : home_url)
          return false
        end
      end
    end
    
  end
end
