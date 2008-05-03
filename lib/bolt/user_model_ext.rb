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
  # Extensions to the user model to allow for authentication and
  # authorization.  You can control which of your ActiveRecord models
  # is considered to be the user model by setting the user_model
  # option in the Bolt::Config class.
  module UserModelExt
    
    ################################################################################
    # This method is called when this module is included into the user model.
    def self.included (klass) # :nodoc:
      # Do a safety check, make sure the users table has the correct foreign key
      if klass.table_exists? and !klass.columns.map(&:name).include?('bolt_identity_id')
        raise "#{klass} is missing the bolt_identity_id column" unless $0.match(/\/rake$/)
      end

      # Protect the bolt_identity_id column
      klass.attr_protected(:bolt_identity_id)

      # Additional validations that need to be added to the user model
      klass.validate do |record|
        # Transfer errors from the Bolt::Identity model to the record
        if account = record.instance_variable_get(:@bolt_identity)
          account.errors.full_messages.each {|m| record.errors.add_to_base(m)}
        end
      end
      
      klass.has_and_belongs_to_many(:roles, :join_table => 'roles_users')
      klass.has_many(:allowances,  :through => :role)
      klass.has_many(:permissions, :through => :allowances)
      
      # only add the following methods if they don't exist
      unless klass.instance_methods.include?('name_with_email')
        klass.send(:include, Bolt::UserModelExt::NameWithEmail)
      end
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

    ################################################################################
    # Create an identity account to match this user account.  The
    # options hash controls how the identity account is created:
    # 
    # +user_name+:: The method to call on the user model to get the user name, defaults to :email
    # +openid_url+:: Can be used instead of a user_name if using OpenID
    # +password+:: The plain text password for this identity
    # +confirmation+:: An optional password confirmation, will be tested against the password
    # +activation+:: Create the identity, but require activation before it can be used
    #
    # If a block is given, it will be called after an identity has
    # been created and successfully saved.  It is passed the new
    # identity.  
    #
    # Returns false if there are any problems creating the identity
    # account.  If the identity account was successfully created, the
    # activation code will be returned if activation was requested,
    # otherwise true is returned.
    #
    # If you request activation, you can leave the password blank.
    # Users will be prompted for a password when they activate their
    # account.  If you pass a string as the value for the activation
    # option, the string should be a URL.  In which case, an email
    # will be sent to the user with his activation code.
    def create_bolt_identity (options={}, &block)
      config = {
        :user_name    => :email,
        :openid_url   => nil,
        :password     => :pill,
        :confirmation => :pill,
        :activation   => false,
      }.update(options)

      # create the back-end identity account
      backend = Bolt::Config.backend_class
      user_name = send(config[:user_name]) if config[:user_name]
      identity = backend.new(:user_name  => user_name, :openid_url => config[:openid_url])

      # check to see if we need to set the password for this identity
      if config[:password] != :pill and config[:confirmation] != :pill
        identity.password_with_confirmation(config[:password], config[:confirmation])
      elsif config[:password] != :pill
        identity.password = config[:password]
      end

      # record the account for later error reporting
      @bolt_identity = identity

      activation_url = config[:activation] if config[:activation].is_a?(String)
      require_activation = config[:activation]
      
      begin
        ActiveRecord::Base.transaction do
          identity.require_activation!(activation_url) if require_activation
          identity.save!
          self.bolt_identity_id = identity.id
          save!
          yield(identity) if block_given?
        end
      rescue
        valid? # force the transfer of error messages
        return false
      end

      return config[:activation] ? identity.activation_code : true
    end
    
    ################################################################################
    # Returns the Bolt identity object that is associated with this user record.
    def bolt_identity
      @bolt_identity ||= Bolt::Config.backend_class.find(bolt_identity_id)
    end

    ################################################################################
    # Only added if it doesn't already exist
    module NameWithEmail
      ################################################################################
      # Returns a name and email address, like so:
      #
      #  Peter Jones <pjones@pmade.com>
      def name_with_email
        result   = name if respond_to?(:name)
        result ||= first_name + ' ' + last_name if respond_to?(:first_name) and respond_to?(:last_name)
        result ||= ''
        result << "<#{email}>" if respond_to?(:email)
        result << "<#{email_address}>" if respond_to?(:email_address)
        raise("your user model needs to have an email (or email_address) attribute") if result.blank?
        result
      end
    end
    
  end
end
