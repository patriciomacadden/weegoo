class PointOfInterest < ActiveRecord::Base
  belongs_to :category
  belongs_to :sub_category
  
  has_many :points_of_interest_users, :class_name => "PointOfInterestUser"
  #has_many :users, :through => :points_of_interest_users, :source => :user
  
  # these are scopes. don't use them for .create!()
  has_many :been_users, :through => :points_of_interest_users, :source => :user, :conditions => { "points_of_interest_users.been" => true }
  has_many :want_to_go_users, :through => :points_of_interest_users, :source => :user, :conditions => { "points_of_interest_users.want_to_go" => true }
  
  set_table_name "points_of_interest"
  
  validates :name, :presence => true
  validates :category, :presence => true
  validates :sub_category, :presence => true
  validates :latitude, :presence => true
  validates :longitude, :presence => true
  
  def self.search(search)
    if search
      where("name LIKE ? or description LIKE ?", "%#{search}%", "%#{search}%")
    else
      scoped
    end
  end
  
  def been_friends(user)
    user_accepted_friendships_ids = []
    
    user.accepted_friendships.each do |friendship|
      user_accepted_friendships_ids << friendship.friend(user).id
    end
    
    been_users_ids = []
    
    been_users.each do |user|
      been_users_ids << user.id
    end
    
    been_friends_ids = user_accepted_friendships_ids & been_users_ids
    
    User.find(been_friends_ids)
  end
  
  def want_to_go_friends(user)
    user_accepted_friendships_ids = []
    
    user.accepted_friendships.each do |friendship|
      user_accepted_friendships_ids << friendship.friend(user).id
    end
    
    want_to_go_users_ids = []
    
    want_to_go_users.each do |user|
      want_to_go_users_ids << user.id
    end
    
    want_to_go_friends_ids = user_accepted_friendships_ids & want_to_go_users_ids
    
    User.find(want_to_go_friends_ids)
  end
end
