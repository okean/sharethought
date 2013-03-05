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

class Micropost < ActiveRecord::Base
  attr_accessible :content
  
  default_scope order: 'microposts.created_at DESC'
  
  scope :from_users_followed_by, ->(user){followed_by(user)}
  
  belongs_to :user
  
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  
  private
  
  def self.followed_by(user)
 following_ids = %(SELECT followed_id FROM relationships
                 WHERE follower_id = :user_id)
  where("user_id IN (#{following_ids}) OR user_id = :user_id",
        { user_id: user })
  end
end
