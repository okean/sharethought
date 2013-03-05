# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Micropost do
  
  before(:each) do
    @user = FactoryGirl.create(:user)
    @attr = {content: "some content"}
  end
  
  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)
  end
  
  describe "user associations" do
    
    before(:each) do
      @micropost = @user.microposts.create!(@attr)
    end
    
    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end
    
    it "should have the right user asigned" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end
  
  describe "validations" do
    
    it "should require a user_id" do
      Micropost.new(@attr).should_not be_valid
    end
    
    it "should require a content" do
      @user.microposts.build(content: " ").should_not be_valid
    end
    
    it "should reject long content" do
      @user.microposts.build(content: 'a' * 141).should_not be_valid
    end
  end
  
  describe "from_users_followed_by" do
    
    before(:each) do
      @followed_user = FactoryGirl.create(:user, email: FactoryGirl.generate(:email))
      @another_user = FactoryGirl.create(:user, email: FactoryGirl.generate(:email))
      
      @user_post = @user.microposts.create!(content: "foo")
      @followed_post = @followed_user.microposts.create!(content: "foo")
      @another_user = @another_user.microposts.create!(content: "foo")
      
      @user.follow!(@followed_user)
    end
    
    it "should have from_users_followed_by class method" do
      Micropost.should respond_to(:from_users_followed_by)
    end
    
    it "should include followed user's micropost" do
      Micropost.from_users_followed_by(@user).should include(@followed_post)
    end
    
    it "should include own user's micropost" do
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end
    
    it "should not include other user's micropost" do
      Micropost.from_users_followed_by(@user).should_not include(@another_user)
    end
  end
end
