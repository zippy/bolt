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
require 'digest/md5'
require 'digest/sha2'

################################################################################
module Bolt
  
  ################################################################################
  # Methods for encoding text, such as making password salt, and
  # SHA256 digests.
  module Encode

    ################################################################################
    # Make a SHA256 and salt encoded password.
    def self.mkpasswd (plain, salt)
      Digest::SHA256.hexdigest(plain + salt)
    end

    ################################################################################
    # Make a salt string.
    def self.mksalt
      [Array.new(6) {rand(256).chr}.join].pack('m').chomp
    end
    
    ################################################################################
    # Make a Base64 encoded token string.  The input text will be
    # passed through Digest::MD5, and then Base64 encoded, with some
    # small changes to make it useful in a URL.
    #
    # Example:
    #
    #  mktoken('foo') # => rL0Y20zC-Fzt72VPzMSk2A
    def self.mktoken (input)
      hash = Digest::MD5.new
      hash << input
      hash.digest.to_a.pack('m*').tr('/+', '_-')[0..-4]
    end
    
  end
end
