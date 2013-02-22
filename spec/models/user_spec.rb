# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
end
