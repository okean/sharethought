class Micropost < ActiveRecord::Base
  attr_accessible :content
  
  default_scope order: 'microposts.created_at DESC'
  
  belongs_to :user
  
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
end
