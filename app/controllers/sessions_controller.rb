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
class SessionsController < ApplicationController

  ################################################################################
  # Skip the Rauth authenticate filter (if it's in use)
  skip_before_filter(:authenticate)

  ################################################################################
  # Don't put passwords in the log file
  filter_parameter_logging(:pass)

  ################################################################################
  # Nothing to see here, go to new.
  def index
    redirect_to(:action => :new)
  end

  ################################################################################
  # You must create a form with two fields: login and password.  Place the
  # template in app/views/sessions/new.rhtml
  def new
    # If someone is already logged in, skip this step
    login(current_user) and return if logged_in?
  end

  ################################################################################
  # Login.
  def create
    user_model = self.class.rauth_options[:user_model].constantize
    backend    = Rauth::Bridge.backend

    if account = backend.authenticate(params[:login], params[:password])
      if user = user_model.find_by_account_id(account.id)
        login(user) and return
      elsif user_model.respond_to?(:create_from_account)
        user = user_model.create_from_account(account)
        if user.valid? and !user.new_record?
          login(user) and return
        else
          raise("#{user_model}.create_from_account did not create a valid model instance")
        end
      else
        message  = "An account for #{params[:login]} was found, "
        message << "but there is no matching #{user_model} record. "
        message << "In addition, the #{user_model} model does not have "
        message << "a create_from_account class method."
        raise(message)
      end
    end

    @login_error = "The credentials you entered are incorrect, please try again."
    render(:action => :new)
  end

  ################################################################################
  # Logout.
  def destroy
    self.current_user = nil
    redirect_to(self.class.rauth_options[:after_logout_url])
  end

  ################################################################################
  private

  ################################################################################
  def login (user)
    self.current_user = user
    redirect_to(session[:rauth_after_login] || self.class.rauth_options[:after_login_url])
    session[:rauth_after_login] = nil
    true
  end

end
