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
    @@clean_username = true
    cattr_accessor(:clean_username)
    
    ################################################################################
    @@min_pass_length = 6
    cattr_accessor(:min_password_length)
    
    ################################################################################
    @@password_must_match = /./
    cattr_accessor(:password_must_match)
    
    ################################################################################
    @@password_error_message = 'Please choose a valid password'
    cattr_accessor(:password_error_message)
    
    ################################################################################
    @@allow_blank_password = false
    cattr_accessor(:allow_blank_password)
    
    ################################################################################
    @@enable_openid = false
    cattr_accessor(:enable_openid)

    ################################################################################
    # Returns the class of the user model.  You configure the user
    # model using Bolt::Config.user_model, not this method.
    def self.user_model_class
      user_model.to_s.constantize
    end
    
  end
end
