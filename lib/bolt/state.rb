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
      if !session[:user_id].nil? 
        expiration = Bolt::Config.session_expiration_time
        last_action_key = Bolt::Config.store_last_action_time_in_session
        the_time_num = last_action_key ? session[last_action_key] : (session.model.updated_at.to_i ||= 0)
        if !expiration
          true
        else
          if Time.now.to_i - the_time_num < expiration
            true
          else
            self.current_user= nil
            session[:bolt_after_login] = request.request_uri if Bolt::Config.record_url
            flash[:notice] = Bolt::Config.session_expiration_notice if Bolt::Config.session_expiration_notice
            nil
          end
        end
      end
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

    ################################################################################
  	# Return a hash of user_ids and last_action times of all users with currently valid sessions
  	def get_logged_in_users
  		raise "Sessions need to be stored in ActiveRecordStore to determine logged in users" if !/ActiveRecordStore/.match(ApplicationController.session_store.to_s)
  		expiration = Bolt::Config.session_expiration_time
      last_action_key = Bolt::Config.store_last_action_time_in_session
      users_hash = {}
  		@sessions = CGI::Session::ActiveRecordStore.session_class.find(:all) 
  		@sessions.each do |session|
  			data_hash = CGI::Session::ActiveRecordStore.session_class.unmarshal(session[:data])
  			if the_user_id = data_hash[:user_id]
  				the_time_num = last_action_key ? data_hash[last_action_key] ||= 0 : (session.updated_at.to_i ||= 0)
  				if !expiration || (Time.now.to_i - the_time_num < expiration)
  					users_hash[the_user_id] = Time.at(the_time_num).utc
  				end
  			end
  		end
  		users_hash
  	end

  end
end
