#!/usr/bin/env ruby
################################################################################
#
# Copyright (C) 2006-2007 pmade inc. (Peter Jones pjones@pmade.com)
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
ENV['RAILS_ENV'] = ARGV.first if ARGV.length == 1

################################################################################
require File.dirname(__FILE__) + '/../config/environment'
require 'highline/import'

################################################################################
user = User.new({
  :first_name  => ask("Given Name (first name): "),
  :last_name   => ask("Family Name (last name): "),
  :email       => ask("Email Address: "),
})

password = loop do 
  p1 = ask("Password: ") {|q| q.echo = '*'}
  p2 = ask("Confirm Password: ") {|q| q.echo = '*'}
  break p1 if p1 == p2
  say("Password Mismatch, Try Again")
end

unless Rauth::Bridge.create_account(user, :user_name => user.email, :password => password)
  raise "Account NOT created: #{user.errors.full_messages}"
end
