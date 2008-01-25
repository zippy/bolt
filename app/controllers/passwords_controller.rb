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
class PasswordsController < ApplicationController

  ################################################################################
  # Skip the Bolt authenticate filter (if it's in use)
  skip_before_filter(:authenticate)
  
  ################################################################################
  # Re-enable the Bolt authenticate filter for the actions that
  # require the user to be logged in.
  require_authentication(:except => [:index, :forgot, :edit, :update])

  ################################################################################
  # Don't put passwords in the log file, it's just not nice
  filter_parameter_logging(:pass)

  ################################################################################
  # Do the right thing based on the state of the current user
  def index
    if logged_in?
      session[:bolt_after_login] ||= request.env["HTTP_REFERER"]
      redirect_to(:action => :new)
    else
      redirect_to(:action => :forgot)
    end
  end

  ################################################################################
  # Show the form for a logged in user to change their password (new password)
  def new
    session[:bolt_after_login] ||= request.env["HTTP_REFERER"]
  end
  
  ################################################################################
  # Attempt to change the password for a logged in user (create password)
  def create
    @identity = current_user.bolt_identity
    args = [params[:current], params[:password], params[:confirmation]]

    if @identity.change_password(*args) and @identity.save
      redirect_to(session[:bolt_after_login] || Bolt::Config.after_login_url)
      session[:bolt_after_login] = nil
    else
      @password_error = @identity.errors.full_messages.join("\n")
      render(:action => 'new')
    end
  end
  
  ################################################################################
  # Help a user change his password when it was forgotten
  def forgot
    if !params[:login].blank? and
        identity = Bolt::Config.backend_class.find_by_user_name(params[:login])
    then
      identity.reset_code! if identity.reset_code.blank? # keep old reset code
      BoltNotifications.deliver_password_reset_notice(identity.user_model_object, identity, password_path(identity.reset_code))
      redirect_to(:action => 'resetcode')
    end
  end
  
  ################################################################################
  # Allow the user to enter a password reset code.
  def resetcode
    render(:action => 'show')
  end
  
  ################################################################################
  # Show the form necessary to reset a password when you're not logged
  # in.  This is like the resetcode action, except the reset code was
  # given in the URL in the :id param.
  def show
  end
  
  ################################################################################
  # Reset a password for someone who is not logged in, but has a reset code
  def update
    args = [params[:login], params[:id], params[:password], params[:confirmation]]
    identity = Bolt::Config.backend_class.reset_password!(*args)
    login(identity.user_model_object) and return if identity and identity.valid?
    @reset_error = identity.errors.full_messages.join("\n") if identity
    @reset_error ||= 'Invalid password reset code.'
    render(:action => 'show')
  end
  
  ################################################################################
  private
  
  ################################################################################
  include(Bolt::BoltControllerMethods)

  ################################################################################
  # Rails 2.0 CSRF Security
  csrf_attack_prevention(:only => [:create, :update])
    
end
