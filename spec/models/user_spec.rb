# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean          default(FALSE)
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = {name: "Test User",
             email: "test@user.com",
             password: "foobar",
             password_confirmation: "foobar"}
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    User.new(@attr.merge(name: "")).should_not be_valid
  end
  
  it "should require an email" do
    User.new(@attr.merge(email: "")).should_not be_valid
  end
  
  it "shoudl reject names that are too long" do
    long_name = 'a' * 51
    User.new(@attr.merge(name: long_name))
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicated email indetical up to case" do
    User.create!(@attr)
    User.new(@attr.merge(email: @attr[:email].upcase)).should_not be_valid
  end
  
  it "should require a password" do
    User.create(@attr.merge(password: "")).should_not be_valid
  end
  
  it "should require a matching password confirmation value" do
    User.create(@attr.merge(password_confirmation: "invalid")).should_not be_valid
  end
  
  it "should reject short passwords" do
    short_password = 'a' * 5
    User.create(@attr.merge(password: short_password))
  end
  
  it "should reject long passwords" do
    long_password = 'a' * 41
    User.create(@attr.merge(password: long_password))
  end
  
  describe "password encryption" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
      
      it "should be true if password matches" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should be false if password doesn't match" do
        @user.has_password?("invalid").should be_false
      end
    end
    
    describe "authenticate method" do
      
      it "should return nil on email/password mismatch" do
        User.authenticate(@attr[:email], "invalid").should be_nil
      end
      
      it "should return nil for an email address with no user" do
        User.authenticate("bar@baz.com", @attr[:password]).should be_nil
      end
      
      it "should return the user on email/password match" do
        User.authenticate(@attr[:email], @attr[:password]).should == @user
      end
    end
  end
  describe "admin attribute" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be an admin by default" do
      @user.should_not be_admin
    end
    
    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  
  describe "micropost association" do
    before(:each) do
      @user = User.create!(@attr)
      @mp1 = FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
      @mp2 = FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end
    
    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end
    
    it "should have right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    it "should destroy associated miroposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
    
    describe "status feed" do
      
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      
       it "should include user's microposts" do
         @user.feed.should include(@mp1)
         @user.feed.should include(@mp2)
       end
       
       it "should not include a different user's microposts" do
         @mp3 = FactoryGirl.create(:micropost, user: FactoryGirl.create(
                                   :user, email: FactoryGirl.generate(:email)))
         @user.feed.should_not include(@mp3)
       end
       
       it "should include microposts of followed users" do
         followed_user = FactoryGirl.create(:user, email: FactoryGirl.generate(:email))
         mp3 = FactoryGirl.create(:micropost, user: followed_user)
         @user.follow!(followed_user)
         @user.feed.should include(mp3)
       end
    end
  end
  
  describe "relationships" do
    
    before(:each) do
      @user = FactoryGirl.create(:user)
      @followed = FactoryGirl.create(:user,
                                     email: FactoryGirl.generate(:email))
    end
    
    it "should have relationships attribute" do
      @user.should respond_to(:relationships)
    end
    
    it "should have a following method" do
      @user.should respond_to(:following)
    end
    
    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end
    
    it "should have a following? method" do
      @user.should respond_to(:following?)
    end
    
    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end
    
    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end
    
    it "should unfollow another user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end
    
    it "should have a reverse_relationships attribute" do
      @user.should respond_to(:reverse_relationships)
    end
    
    it "should have a followers attribute" do
      @user.should respond_to(:followers)
    end
    
    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
end
