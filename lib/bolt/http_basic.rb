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
  # Attempt to authenticate a user via HTTP Basic authentication.
  module HttpBasic

    ################################################################################
    # Using information contained in the given controller, try to
    # authenticate using HTTP Basic.
    def self.authenticate (controller)
      header = controller.request.env['HTTP_AUTHORIZATION']
      return unless m = header.to_s.match(/^Basic\s+(.+)$/i)
      backend = Bolt::Config.backend_class
      user, pass = m[1].unpack("m*").to_s.split(/:/, 2)
      return unless identity = backend.authenticate(user, pass)
      user_obj = identity.user_model_object
      controller.current_user = user_obj
      user_obj
    end
    
  end
end
