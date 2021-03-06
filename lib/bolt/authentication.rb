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
  # Methods added to all controllers for authentication purposes.
  # Authentication is the process of verifying that someone is who
  # they claim to be.
  module Authentication
    
    ################################################################################
    def self.included (klass) #:nodoc:
      klass.send(:extend,  Bolt::Authentication::ClassMethods)
      klass.send(:include, Bolt::Authentication::InstanceMethods)
    end
    
    ################################################################################
    # Methods added to all controllers as class methods
    module ClassMethods
      ################################################################################
      # Create a before_filter that will ensure that the current user is
      # logged in.  The options passed to this method are passed directly
      # to before_filter, so any options that it accepts can be used here
      # as well.
      #
      # Here are some examples:
      #
      #  require_authentication
      #
      #  require_authentication(:only => :create)
      #
      #  require_authentication(:except => [:show, :rss])
      #
      # You can use this on any controller, or place it in your
      # ApplicationController to make it apply to all controllers.  In
      # which case, you can remove it from specific controllers using
      # skip_before_filter:
      #
      #  skip_before_filter(:authenticate)
      def require_authentication (*args)
        before_filter(:authenticate, *args)
      end
    end
    
    ################################################################################
    # Methods added to all controllers as instance methods.
    module InstanceMethods
      ################################################################################
      # Ensure that the current user is logged in.  You can use this
      # method directly if necessary, but is intended to be used from
      # within a before_filter (the one created when you call
      # require_authentication).
      def authenticate
        user = self.current_user if self.logged_in? && !expired!
        user ||= Bolt::HttpBasic.authenticate(self) if Bolt::Config.use_http_basic

        if !user or (user.respond_to?(:enabled?) and !user.enabled?)
          store_and_redirect(login_url)
          return false
        end

        user
      end

      def expired!
        # never expire if we aren't configured with an expiration time..
        return false if !(expiration = Bolt::Config.session_expiration_time)

        last_action_key = Bolt::Config.store_last_action_time_in_session
        the_time_num = last_action_key ? session[last_action_key] : (session.model.updated_at.to_i ||= 0)

        # return false still in the time window
        return false if Time.now.to_i - the_time_num < expiration

        # clear the current session and return true setting things up to be able to
        # redirect after a successfull login
        expired_user = session[:user_id]
        self.current_user= nil
        session[:bolt_expired_user] = expired_user
        flash[:notice] = Bolt::Config.session_expiration_notice if Bolt::Config.session_expiration_notice
        true
      end

      def store_and_redirect(url)
        if Bolt::Config.record_url
          if request.method != :get
            if params[:authenticity_token]
              params[:authenticity_token] = form_authenticity_token
            end
            session[:bolt_after_login_post_params] = params
          end
          session[:bolt_after_login] = request.request_uri
        end
        redirect_to url
      end
    end
    
  end
end
