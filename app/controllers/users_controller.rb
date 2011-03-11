class UsersController < ApplicationController
  def index
    if params[:search]
      @users = User.search(params[:search])
    else
      @users = []
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def add_as_friend
    @user = User.find(params[:id])
    
    current_user.friendships.create!(:user_b_id => @user.id)
  end
  
  def accept_friendship
    @user = User.find(params[:id])
    
    @friendship = Friendship.find(params[:friendship_id])
    @friendship.accept
    
    redirect_to(@user, :notice => "You and #{@friendship.user_a.full_name} are now friends.")
  end
  
  def decline_friendship
    @user = User.find(params[:id])
    
    @friendship = Friendship.find(params[:friendship_id])
    @friendship.delete
    
    redirect_to(@user, :notice => "You and #{@friendship.user_a.full_name} are not friends.")
  end
  
  def friendship_requests
    @user = User.find(params[:id])
  end
  
  def friends
    @user = User.find(params[:id])
  end
end
