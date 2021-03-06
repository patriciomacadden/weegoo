class Venue < ActiveRecord::Base
  # Associations
  belongs_to :category
  belongs_to :sub_category
  belongs_to :user
  
  has_many :comments, :as => :commentable
  has_many :images, :as => :imageable
  
  has_many :events
  has_many :users_venues, :class_name => 'UserVenue'
  
  has_many :visitors, :class_name => 'User', :through => :users_venues, :source => :user, :conditions => 'users_venues.visited = 1'
  has_many :possible_visitors, :class_name => 'User', :through => :users_venues, :source => :user, :conditions => 'users_venues.to_go = 1'
  
  # Validations
  validates :name, :presence => true, :uniqueness => true
  validates :category, :presence => true
  validates :sub_category, :presence => true
  validates :latitude, :presence => true
  validates :longitude, :presence => true
  
  acts_as_ferret :fields => [
    :name,
    :description
  ], :additional_fields => [
    :category,
    :sub_category
  ]
  
  # Callbacks
  # because permalink_fu does not escape the name automatically:
  before_save :handle_permalink
  has_permalink :name, :update => true
  
  after_create :create_venue_created_activity
  
  PER_PAGE = 20
  
  def self.search(search)
    if search
      where('(name LIKE ? OR description LIKE ?)', "%#{search}%", "%#{search}%").order('name ASC')
    else
      scoped
    end
  end
  
  def to_param
    permalink
  end
  
  def can_delete?(user)
    visitors.size == 0 and possible_visitors.size == 0 and self.user == user
  end
  
  def can_edit?(user)
    self.user == user
  end
  
  def self.most_visited
    venues = []
    
    sql = 'SELECT users_venues.*, venues.name, COUNT(*) FROM users_venues JOIN venues ON venues.id = users_venues.venue_id WHERE visited = 1 GROUP BY venue_id ORDER BY COUNT(*) DESC LIMIT 10'
    
    users_venues = UserVenue.find_by_sql(sql)
    
    users_venues.each do |user_venue|
      venues << user_venue.venue
    end
    
    venues
  end
  
  def to_s
    name
  end
  
  protected
  
  def handle_permalink
    self.permalink = PermalinkFu.escape self.name
  end
  
  private
  
  def create_venue_created_activity
    VenueCreatedActivity.create!(:user_a_id => self.user.id, :venue_id => self.id)
  end
end
