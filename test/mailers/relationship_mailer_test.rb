require 'test_helper'

class RelationshipMailerTest < ActionMailer::TestCase
  test "follow_notification" do
    user = users(:hoge)
    follower = users(:fuga)
    mail = RelationshipMailer.follow_notification(user, follower)
    assert_equal "#{follower.name} started following you", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.name, mail.body.encoded
    assert_match follower.name, mail.body.encoded
  end

  test "unfollow_notification" do
    user = users(:hoge)
    follower = users(:fuga)
    mail = RelationshipMailer.unfollow_notification(user, follower)
    assert_equal "#{follower.name} unfollowed you", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.name, mail.body.encoded
    assert_match follower.name, mail.body.encoded
  end
end
