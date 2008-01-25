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
  module Initializer
    
    ################################################################################
    # Configure Bolt, and then allow it to instrument your Rails
    # application based on the settings.  If you give this method a
    # block, it will be yielded the Bolt::Config class for you to use:
    #
    #  Bolt::Initializer do |bolt|
    #    bolt.application_name = 'My Fancy Rails App'
    #  end
    def self.run (&block)
      # Give the caller a chance to change bolt settings before we
      # start using them.
      yield(Bolt::Config) if block
      require_dependency(Bolt::Config.user_model.to_s)
      augment_user_model
    end

    ################################################################################
    def self.augment_user_model # :nodoc:
      Bolt::Config.user_model_class.send(:include, Bolt::UserModelExt)
    end

  end
end
