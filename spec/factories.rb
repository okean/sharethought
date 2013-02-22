FactoryGirl.define do
  factory :user do
    name "Test User"
    email  "test@user.com"
    password "foobar"
    password_confirmation "foobar"
  end
  
  sequence :email do |n|
    "test_#{n}@user.com"
  end
end