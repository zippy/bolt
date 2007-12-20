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
    @@application_name = 'Your Rails App'
    cattr_accessor(:application_name)
    
    ################################################################################
    # The email address to use as the sender address when Bolt sends out emails.
    @@email_from = 'noreply@example.com'
    cattr_accessor(:email_from)
    
    ################################################################################
    # The class of your ActiveRecord model used to hold information about users.
    @@user_model = :user
    cattr_accessor(:user_model)
    
    ################################################################################
    # The default URL to send someone after they have successfully logged in.
    @@after_login_url = '/'
    cattr_accessor(:after_login_url)
    
    ################################################################################
    # The URL to send someone after they have logged out.
    @@after_logout_url = '/'
    cattr_accessor(:after_logout_url)
    
    ################################################################################
    # If true, record the URL that was being requested when the system
    # decided to do a redirect to the login page.  The user will then
    # be returned to the recorded URL after login, instead of the
    # default URL.
    @@record_url = true
    cattr_accessor(:record_url)

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
    @@min_password_length = 6
    cattr_accessor(:min_password_length)
    
    ################################################################################
    # A regular expression that passwords must match.
    @@password_must_match = /./
    cattr_accessor(:password_must_match)
    
    ################################################################################
    # An error message displayed when the validation regular
    # expression doesn't match.  The validation regular expression is
    # configured with the password_must_match option.
    @@password_error_message = 'Please choose a valid password'
    cattr_accessor(:password_error_message)
    
    ################################################################################
    # Allow OpenID authentication.  (Not yet implemented)
    @@enable_openid = false
    cattr_accessor(:enable_openid)
    
    ################################################################################
    # The authentication back-end class to use.
    @@backend = :identity
    cattr_accessor(:backend)

    ################################################################################
    # What to call the user name in forms (such as the login form)
    @@user_name_label = 'Email Address'
    cattr_accessor(:user_name_label)
    
    ################################################################################
    # Returns the class of the user model.  You configure the user
    # model using Bolt::Config.user_model, not this method.
    def self.user_model_class
      load_class_for(user_model)
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
