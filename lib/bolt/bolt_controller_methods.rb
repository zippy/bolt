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
        self.current_user = user
        redirect_to(session[:bolt_after_login] || Bolt::Config.after_login_url)
        session[:bolt_after_login] = nil
        true
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
        if respond_to?(:protect_from_forgery)
          secret   = request_forgery_protection_options[:secret]
          secret ||= generate_secret
          protect_from_forgery(options.merge(:secret => secret))
        end
      end
    end
    
  end
end
