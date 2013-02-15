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
    @attr = {name: "Test User", email: "test@user.com"}
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
  
end
