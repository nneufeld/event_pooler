require 'test_helper'

class UserTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :users

  test "auth" do
    #check that we can login we a valid user
    assert_equal  @bob, User.authenticate("bob@bob.com", "test")
    #wrong username
    assert_nil    User.authenticate("nonbob@bob.com", "test")
    #wrong password
    assert_nil    User.authenticate("bob@bob.com", "wrongpass")
    #wrong login and pass
    assert_nil    User.authenticate("nonbob@bob.com", "wrongpass")
  end

end
