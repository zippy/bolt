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
  # Code for dealing with the Bolt authentication system.
  module Authentication

    ################################################################################
    # Class methods added to ActiveRecord::Base
    module ActiveRecordClassMethods
      ################################################################################
      def acts_as_user (options_for_auth_source={})
        Rauth::Bridge.backend.rauth_options.update(options_for_auth_source)

        if self.table_exists? and !self.columns.map(&:name).include?('account_id')
          raise "#{self} is missing the account_id column" 
        end

        self.validate do |record|
          if account = record.instance_variable_get(:@rauth_account)
            account.errors.full_messages.each {|m| record.errors.add_to_base(m)}
          end
        end

        define_method(:rauth_loaded?) {true}
      end
    end

    ################################################################################
    # Class methods added to ActionController::Base
    module ActionControllerClassMethods
      ################################################################################
      DEFAULT_MODEL_FILE  = "#{RAILS_ROOT}/app/models/user.rb"
      DEFAULT_MODEL_CLASS = 'User'

      ################################################################################
      # Enables authentication processing on the calling controller.
      # Automatically placed on the ApplicationController if you don't do it
      # yourself.
      #
      # If you want to override any of the options described below, you can
      # explicitly call enable_authentication on your ApplicationController.
      #
      # Options:
      #
      # *:after_login_url  The URL to send the user to after logging in
      # *:after_logout_url The URL to send the user to after logging out
      # *:record_url       Should be true or false, see below
      # *:user_model       The class of your user model, default is User
      #
      # The record_url option, if true (the default), causes Rauth to record
      # the URL that was being requested when a redirection to the login form
      # was necessary. After a successful login, the user will be redirected
      # back to the original URL that prompted the login.
      #
      # This method only configures the authentication system.  To require
      # authentication for a specific controller you need to use the
      # require_authentication method.  It inserts a before_filter for you.
      # Here are some examples:
      #
      #  require_authentication
      #
      #  require_authentication(:only => :create)
      #
      #  require_authentication(:except => [:show, :rss])
      def enable_authentication (options={})
        config = {
          :after_login_url  => '/',
          :after_logout_url => '/',
          :record_url       => true,
          :user_model       => nil,
        }.update(options)

        # the following code prevents the plugin from blowing up when the
        # Rails application does not yet have a User model.
        if config[:user_model].nil? and File.exist?(DEFAULT_MODEL_FILE)
          config[:user_model] = DEFAULT_MODEL_CLASS
        end

        class_eval <<-EOT
          def self.rauth_loaded? () true end
          cattr_accessor(:rauth_options)
          @@rauth_options = config

          def self.require_authentication (options={})
            before_filter(:authenticate, options)
          end
        EOT

        self.send(:include, Rauth::Authentication::ActionControllerInstanceMethods)
        self.send(:include, Rauth::State)
        self.add_template_helper(Rauth::State)
      end
    end

    ################################################################################
    module ActionControllerInstanceMethods
      ################################################################################
      # Ensure that the current user is logged in
      def authenticate
        options = self.rauth_options
        user = self.current_user if self.logged_in?

        if !user or (user.respond_to?(:enabled?) and !user.enabled?)
          session[:rauth_after_login] = request.request_uri if options[:record_url]
          redirect_to(login_url())
          return false # stop the filter chain if called from a filter
        end

        user
      end
    end

  end
end
################################################################################
