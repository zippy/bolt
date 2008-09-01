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
  # Methods added to all of the Bolt controllers
  module BoltControllerMethods
    
    ################################################################################
    def self.included (klass)
      klass.send(:include, Bolt::BoltControllerMethods::InstanceMethods)
      klass.send(:extend,  Bolt::BoltControllerMethods::ClassMethods)
    end
    
    ################################################################################
    module InstanceMethods
      ################################################################################
      # Login the given user, and redirect to the correct page.  Returns
      # true so that you can use it in a controller action, like this:
      # 
      #  login(someone) and return
      def login (user)
        last_action_key = Bolt::Config.store_last_action_time_in_session
        session[last_action_key] = Time.now.to_i if last_action_key

        self.current_user = user

        # update the session last action time so that if we happen to be logging in after session
        # expiration the ensuing authentication check won't just re-expire
        session.model.save unless Bolt::Config.store_last_action_time_in_session

        if user.respond_to?(:login_action)
          user.login_action(request)
        end
        redirect_after_login

        true
      end

      def redirect_after_login
        # if this redirect was because of an expiration make sure that the newly logged in user
        # is the same user that expired
        if session[:bolt_expired_user] && self.current_user.id != session[:bolt_expired_user]
          session[:bolt_after_login] = nil
          session[:bolt_after_login_post_params] = nil
        end
        return_params = session[:bolt_after_login_post_params]
        if return_params
          session[:bolt_after_login_post_params] = nil
          redirect_post(return_params)
        else
          redirect_to(session[:bolt_after_login] || Bolt::Config.after_login_url)
        end
        session[:bolt_after_login] = nil
      end

      def redirect_post(redirect_post_params)
        controller_name = redirect_post_params[:controller]
        controller = "#{controller_name.camelize}Controller".constantize
        # Throw out existing params and merge the stored ones
        request.parameters.reject! { true }
        request.parameters.merge!(redirect_post_params)
        controller.process(request, response)
        if response.redirected_to
          @performed_redirect = true
        else
          @performed_render = true
        end
      end
    end
    
    ################################################################################
    module ClassMethods
      ################################################################################
      # Generate a secret key used for CSRF attack prevention
      def generate_secret
        Bolt::Config.forgery_secret || "#{Bolt::Encode.mksalt}#{Time.now.to_i}"
      end
      
      ################################################################################
      # Use the Rails 2.0 CSRF attack prevention code if available
      def csrf_attack_prevention (options={})
        return
        if respond_to?(:protect_from_forgery)
          secret   = request_forgery_protection_options[:secret]
          secret ||= generate_secret
          protect_from_forgery(options.merge(:secret => secret))
        end
      end
    end
    
  end
end
