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
  # The Bolt::Config class is used to set configuration options for
  # Bolt.  You should set options in one of your environment files.
  # 
  # Here is an example of how to use this class to change
  # configuration options for Bolt:
  #
  #  Bolt::Config.after_login_url  = '/some/place'
  #  Bolt::Config.after_logout_url = '/some/other/place'
  class Config
    
    ################################################################################
    # The public name of your Rails application
    cattr_accessor(:application_name)
    @@application_name = 'Your Rails App'
    
    ################################################################################
    # The email address to use as the sender address when Bolt sends out emails.
    cattr_accessor(:email_from)
    @@email_from = 'noreply@example.com'
    
    ################################################################################
    # The class of your ActiveRecord model used to hold information about users.
    cattr_accessor(:user_model)
    @@user_model = :user
    
    ################################################################################
    # The default URL to send someone after they have successfully logged in.
    cattr_accessor(:after_login_url)
    @@after_login_url = '/'
    
    ################################################################################
    # The URL to send someone after they have logged out.
    cattr_accessor(:after_logout_url)
    @@after_logout_url = '/'
    
    ################################################################################
    # If true, record the URL that was being requested when the system
    # decided to do a redirect to the login page.  The user will then
    # be returned to the recorded URL after login, instead of the
    # default URL.
    cattr_accessor(:record_url)
    @@record_url = true

    ################################################################################
    # If true, the user_name will always be cleaned before being used.
    # This is important for most user names, including the situation
    # where you are using an email address as the user name.  Cleaning
    # the user name involves stripping leading and trailing white
    # space, and converting the user name to all lowercase.
    @@clean_user_name = true
    cattr_accessor(:clean_user_name)
    
    ################################################################################
    # The minimum number of characters that a password must have.
    cattr_accessor(:min_password_length)
    @@min_password_length = 6
    
    ################################################################################
    # A regular expression that passwords must match.
    cattr_accessor(:password_must_match)
    @@password_must_match = /./
    
    ################################################################################
    # An error message displayed when the validation regular
    # expression doesn't match.  The validation regular expression is
    # configured with the password_must_match option.
    cattr_accessor(:password_error_message)
    @@password_error_message = 'Please choose a valid password'
    
    ################################################################################
    # Allow OpenID authentication.  (Not yet implemented)
    cattr_accessor(:enable_openid)
    @@enable_openid = false
    
    ################################################################################
    # The authentication back-end class to use.
    cattr_accessor(:backend)
    @@backend = :identity

    ################################################################################
    # What to call the user name in forms (such as the login form)
    cattr_accessor(:user_name_label)
    @@user_name_label = 'Email Address'

    ################################################################################
    # How to validate email addresses (if asked to do so)
    cattr_accessor(:email_regex)
    @@email_regex = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    
    ################################################################################
    # The secret to use for forgery prevention in forms.  Taken from
    # the ApplicationController by default.
    cattr_accessor(:forgery_secret)
    @@forgery_secret = nil

    ################################################################################
    # Allow authentication via HTTP Basic
    cattr_accessor(:use_http_basic)
    @@use_http_basic = true
    
    ################################################################################
    # Returns the class of the user model.  You configure the user
    # model using Bolt::Config.user_model, not this method.
    def self.user_model_class
      load_class_for(user_model)
    end

    ################################################################################
    # Returns the full path to the user model source file
    def self.user_model_path
      File.join(RAILS_ROOT, 'app/models', Bolt::Config.user_model.to_s + '.rb')
    end
    
    ################################################################################
    # Returns the class of the back-end authentication interface
    def self.backend_class
      load_class_for(backend)
    end
    
    ################################################################################
    private
    
    ################################################################################
    def self.load_class_for (item)
      item.to_s.camelize.constantize
    end
    
  end
end
