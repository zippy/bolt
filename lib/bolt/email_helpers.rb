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
  # You can include this module in your user model to get some nice
  # validations and helper methods relating to email addresses.
  #
  #  class User < ActiveRecord::Base
  #    include(Bolt::EmailHelpers)
  #  end
  module EmailHelpers

    ################################################################################
    def self.included (klass) # :nodoc:
      klass.send(:extend,  Bolt::EmailHelpers::ClassMethods)
      klass.send(:include, Bolt::EmailHelpers::InstanceMethods)
      
      if Bolt::Config.email_regex
        klass.validates_format_of(:email, :with => Bolt::Config.email_regex)
      end
    end
    
    ################################################################################
    # Methods added as class methods of your user model
    module ClassMethods

      ################################################################################
      # Makes it safe to query a database using an email address.
      def find_by_email (email)
        find(:first, :conditions => {:email => email.downcase.strip})
      end
    end

    ################################################################################
    # Methods added as instance methods to your user model
    module InstanceMethods
      
      ################################################################################
      # Force email address to be lowercase
      def email= (email)
        self[:email] = email.downcase.strip
      end

    end
  end
end

