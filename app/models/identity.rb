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
class Identity < ActiveRecord::Base

  ################################################################################
  validates_uniqueness_of(:user_name)

  ################################################################################
  attr_accessible(:user_name, :openid_url)

  ################################################################################
  # Finder that cleans the user name if necessary
  def self.find_by_user_name (user_name)
    self.find(:first, :conditions => {:user_name => clean_username(user_name)})
  end

  ################################################################################
  # Locate the account with these credentials
  def self.authenticate (user_name, plain_text_password)
    if Bolt::Config.enable_openid 
      raise("OpenID support isn't implemented yet, FIXME!")
    end

    account = self.find(:first, :conditions => {:user_name => clean_username(user_name)})
    return account if account and account.password?(plain_text_password)
    nil # return nil when authentication fails
  end

  ################################################################################
  # Locate the given account and activate it (does not call account.save).
  # You must save the account after it is returned, so that the
  # activation_code will be reset.  Returns nil if no account could be found
  # with the given user_name and code.
  def self.activate (user_name, code)
    if account = self.find_by_user_name_and_activation_code(clean_username(user_name), standardize_code(code))
      account.enabled = true
      account.activation_code = ''
      return account
    end
  end

  ################################################################################
  # Locate the given account and activate it, saving the account before
  # returning it.
  def self.activate! (user_name, code)
    account = activate(user_name, code)
    account.save! if account
    account
  end

  ################################################################################
  # Check to see if the given activation code requires a password to be set
  def self.activation_requires_password? (code)
    account = self.find_by_activation_code(standardize_code(code))
    account ? account.password_hash.blank? : true
  end
  
  ################################################################################
  # Locate an account based on the user_name and a reset code.  If that
  # account can be found, reset the password with the given password and
  # confirmation.
  #
  # Returns nil if no matching account can be found.  Returns an account
  # object if the account could be found.  You should check valid? on the
  # returned account because the password setting might have failed if the
  # password and password confirmation don't match.
  def self.reset_password! (user_name, code, password, confirmation)
    if account = self.find_by_user_name_and_reset_code(clean_username(user_name), standardize_code(code))
      if account.password_with_confirmation(password, confirmation)
        account.reset_code = ''
        account.save
      end

      return account
    end
  end

  ################################################################################
  # Returns the user model object that corresponds to this identity
  # record.  If there isn't a matching user model record, attempt to
  # create it.  All errors raise an exception.
  def user_model_object
    user_model = Bolt::Config.user_model_class

    # simplest case, existing user model record
    user = user_model.find_by_bolt_identity_id(id)
    return user if user
    
    if user_model.respond_to?(:create_from_bolt_identity)
      user = user_model.create_from_bolt_identity(self)
      return user if user.valid? and !user.new_record?
      raise("#{user_model}.create_from_bolt_identity did not create a valid model instance")
    else
      message  = "An account for #{user_name} was found, "
      message << "but there is no matching #{user_model} record. "
      message << "In addition, the #{user_model} model does not have "
      message << "a create_from_bolt_identity class method."
      raise(message)
    end
  end
  
  ################################################################################
  # Check to see if the given plain_text_password matches the encoded
  # password stored in the database.
  def password? (plain_text_password)
    # don't allow logging in with blank passwords
    return false if plain_text_password.blank?
    return false if self.password_hash.blank?
    
    salt = self.password_salt
    pass = self.password_hash
    Bolt::Encode.mkpasswd(plain_text_password, salt) == pass
  end

  ################################################################################
  # Set the encoded password from the given plain text password.
  def password= (plain_text_password)
    @password_valid = nil

    if plain_text_password.blank? or 
      plain_text_password.length < Bolt::Config.min_password_length or
      !plain_text_password.match(Bolt::Config.password_must_match)
    then
      @password_valid = false
      return
    end

    salt = Bolt::Encode.mksalt
    pass = Bolt::Encode.mkpasswd(plain_text_password, salt)
    self.password_salt = salt
    self.password_hash = pass

    [salt, pass]
  end

  ################################################################################
  # Given a plain text password, and a confirmation of that password, set
  # the encoded password if the two match.
  def password_with_confirmation (password, confirmation)
    return unless @password_match = (!password.blank?)
    return unless @password_match = (password == confirmation)
    self.password = password
  end

  ################################################################################
  # Great for changing a password from a form that asks for three passwords,
  # the current password, the new password, and a password confirmation.
  # Returns true if the change was successful, false otherwise. If the
  # password setting was false, you can get the error messages from the errors
  # object.
  def change_password (current_pass, new_pass, confirm_pass)
    return valid? unless @current_password = password?(current_pass)
    password_with_confirmation(new_pass, confirm_pass)
    valid?
  end

  ################################################################################
  # Require that the given account be activated with a code.  If you
  # do this, the password for this identity is allowed to be blank.
  # Users will then be prompted for a password when activating their
  # account.
  #
  # If you want to send out an activation notice email, pass the URL
  # to the activations controller.  You can use the route helper (if
  # inside a controller or view):
  #
  #  activation_url(code)
  def require_activation! (activation_url=nil)
    self.enabled = false
    self.activation_code = Digest::MD5.hexdigest(self.object_id.to_s + Bolt::Encode.mksalt)
    self.activation_code = self.class.standardize_code(self.activation_code)
    
    if activation_url
      # send out an email if so requested
      BoltNotifications.deliver_activation_notice(user_model_object, self, activation_url)
    end
    
    self.activation_code
  end
  
  ################################################################################
  # Check to see if this account requires activation
  def require_activation?
    !self.enabled? and !self.activation_code.blank?
  end

  ################################################################################
  # Create a password reset code for this account
  def reset_code!
    self.reset_code = Digest::MD5.hexdigest(user_name + object_id.to_s + Bolt::Encode.mksalt)
    self.reset_code = self.class.standardize_code(reset_code)
    self.save!
    self.reset_code
  end

  ################################################################################
  # Make sure the user_name column is clean
  def user_name= (name)
    self[:user_name] = self.class.clean_username(name)
  end

  ################################################################################
  # Check the password
  validate do |record|
    if record.instance_variable_get(:@password_valid) == false
      record.errors.add_to_base(Bolt::Config.password_error_message)
    elsif record.instance_variable_get(:@current_password) == false
      record.errors.add_to_base("Current password is incorrect")
    elsif record.instance_variable_get(:@password_match) == false
      record.errors.add_to_base("Password and password confirmation don't match")
    elsif record.password_hash.blank? and record.activation_code.blank?
      record.errors.add_to_base("Password can't be blank")
    end
  end

  ################################################################################
  private
  
  ################################################################################
  # Clean the user name if so configured
  def self.clean_username (user_name)
    Bolt::Config.clean_user_name ? user_name.to_s.strip.downcase : user_name
  end

  ################################################################################
  # Standardize the MD5 codes such as the activation and reset password codes.
  def self.standardize_code (code)
     code.to_s.strip.upcase
  end
  
end
################################################################################
