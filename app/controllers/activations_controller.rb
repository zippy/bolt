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
class ActivationsController < ApplicationController

  ################################################################################
  # Skip the Bolt authenticate filter (if it's in use)
  skip_before_filter(:authenticate)

  ################################################################################
  # Don't put passwords in the log file
  filter_parameter_logging(:pass)

  ################################################################################
  # Prepare the backend authentication class
  before_filter(:prepare_backend)
  
  ################################################################################
  # Nothing to see here, go to new.
  def index
    redirect_to(:action => :new)
  end

  ################################################################################
  # Request an activation code from the user.
  def new
    render(:action => 'show')
  end
  
  ################################################################################
  # Confirm the activation code, and send to the show page if a
  # password needs to be set.
  def create
    prepare_instance_variables
    
    unless @requires_password
      # try to activate the account identified by the given code and login
      account = @backend.activate!(@login, @code)
      login(account.user_model_object) and return if account and account.valid?
    end
    
    # there was either an error, or we need to set a password
    redirect_to(:action => 'show', :id => @code, :login => @login)
  end
  
  ################################################################################
  # Show the activation code, prompt for a user name, and possibly for
  # a password and password confirmation if the user has not yet set
  # his password.
  def show
    prepare_instance_variables
  end
  
  ################################################################################
  # Attempt to active the identity with the given activation code.
  # Setting their password if necessary.
  def update
    prepare_instance_variables
    account = @backend.activate(@login, @code)
    
    if account
      account.password_with_confirmation(params[:password], params[:confirmation]) if @requires_password
      login(account.user_model_object) and return if account.save
      @activation_error = account.errors.full_messages.join("\n")
    else
      @activation_error  = "Invalid activation code or #{Bolt::Config.user_name_label.downcase}."
    end
    
    render(:action => 'show')
  end

  ################################################################################
  # Display a form that prompts for an email address, and then send
  # out an activation email.
  def deliver
    unless params[:login].blank?
      account = @backend.find_by_user_name(params[:login])
      
      if account.nil?
        @deliver_error = "Account not found."
      elsif !account.require_activation?
        @deliver_error = "Account already activated."
      else
        user = account.user_model_object
        url  = activation_url(account.activation_code)
        BoltNotifications.deliver_activation_notice(user, account, url)
        redirect_to(:action => 'new', :login => params[:login])
      end
    end
  end
  
  ################################################################################
  private
  
  ################################################################################
  include(Bolt::BoltControllerMethods)

  ################################################################################
  # Rails 2.0 CSRF Security
  csrf_attack_prevention(:only => [:create, :update])
    
  ################################################################################
  def prepare_backend
    @backend = Bolt::Config.backend_class
  end
  
  ################################################################################
  def prepare_instance_variables
    @code  = params[:id]
    @login = params[:login]
    @requires_password = @backend.activation_requires_password?(@code)
  end

end
