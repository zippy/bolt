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
require 'fileutils'

################################################################################
module ActiveSupport
  module Dependencies

    ################################################################################
    # Allow Bolt to augment the user model after it was reloaded in development mode
    def self.load_file_with_augment_user (*args) # :nodoc:
      result = load_file_without_augment_user(*args)
      path   = Bolt::Config.user_model_path
      
      if File.exist?(path) and FileUtils.identical?(args.first, path)
        Bolt::Initializer.augment_user_model
      end

      result
    end

    class << self
      alias_method_chain(:load_file, :augment_user)
    end

  end
end
