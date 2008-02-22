################################################################################
require File.dirname(__FILE__) + '/../test_helper'

################################################################################
class EncodeTest < Test::Unit::TestCase
  
  ################################################################################
  def test_mktoken
    assert_equal("rL0Y20zC-Fzt72VPzMSk2A", Bolt::Encode.mktoken('foo'))
  end
  
end
