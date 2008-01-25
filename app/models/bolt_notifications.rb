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
class BoltNotifications < ActionMailer::Base

  ################################################################################
  # Send out an activation email to the given user.  You need to pass
  # in the user, identity, and a URL for the activation controller.
  def activation_notice (user, identity, url)
    @from       = Bolt::Config.email_from
    @recipients = user.name_with_email
    @subject    = "Activation Code for #{Bolt::Config.application_name}"
    @body       = {:user => user, :identity => identity, :url => url}
  end

  ################################################################################
  # Send out an email that tells the user how to reset their password.
  def password_reset_notice (user, identity, url)
    @from       = Bolt::Config.email_from
    @recipients = user.name_with_email
    @subject    = "Password Reset Code for #{Bolt::Config.application_name}"
    @body       = {:user => user, :identity => identity, :url => url}
  end
  
end
################################################################################
