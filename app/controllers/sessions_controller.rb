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
class SessionsController < ApplicationController

  ################################################################################
  # Ensure that sessions are enabled.
  session(:disabled => false)
  
  ################################################################################
  # Skip the Bolt authenticate filter (if it's in use)
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
  # Display the login form.
  def new
    # If someone is already logged in, skip this step
    login(current_user) and return if logged_in?
  end

  ################################################################################
  # Log the user in, redirecting to the correct page.
  def create
    backend = Bolt::Config.backend_class

    if identity = backend.authenticate(params[:login], params[:password])
      login(identity.user_model_object) and return
    end

    @login_error = "The credentials you entered are incorrect, please try again."
    render(:action => :new)
  end

  ################################################################################
  # Log the user out, and go to Bolt::Config.after_logout_url.
  def destroy
    self.current_user = nil
    redirect_to(Bolt::Config.after_logout_url)
  end

  ################################################################################
  private

  ################################################################################
  include(Bolt::BoltControllerMethods)
  
  ################################################################################
  # Rails 2.0 CSRF Security
  csrf_attack_prevention(:only => :create)
  
end
