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
  module State

    ################################################################################
    # Check to see if a remote web user has been authenticated.
    # Returns true if the user has authenticated and logged in, false
    # otherwise.
    def logged_in?
      !session[:user_id].nil?
    end

    ################################################################################
    # Get the model object for the logged in user.  If the user is not
    # logged in (if the logged_in? method would return false),
    # current_user will create a new user model object and return that
    # instead.  The class used as the user model is configured using
    # the Bolt::Config#user_model method.
    def current_user
      model = Bolt::Config.user_model_class
      @current_user ||= (logged_in? ? model.find(session[:user_id]) : model.new)
    end

    ################################################################################
    # Set the logged in user, or log the current user out (by giving
    # nil).  Because of a parsing ambiguity in Ruby, you should call
    # this method like so:
    # 
    #  self.current_user = user
    #
    # Otherwise you won't call this method, but will instead create a
    # local variable called current_user.
    def current_user= (user)
      session[:user_id] = user ? user.id : nil
      @current_user = user # to update the @current_user cache
      reset_session if user.nil?
    end

  end
end
