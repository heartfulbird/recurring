class UsersController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    @users = User.order(sort_column + " " + sort_direction).includes(:account)
    unless params[:term].blank?
      @users = @users.lookup(params[:term]) if params[:term].present?
    end
    @users = @users.paginate(:page => params[:page], :per_page => 25)
  end
  
  def new
    @user = User.new
  end
  
  def edit
    @user = User.find_by(id: params[:id])
  end
  
  def edit_password
    @user = User.find_by(id: params[:user_id])
  end
  
  def reset_password
    User.find_by(id: params[:user_id]).send_reset_password_instructions
  end
  
  def create
    @user = User.new(user_params)
    puts @user.inspect
    if @user.save
      puts params[:user][:email]
      if Account.find_by(:email => params[:user][:email])
        Account.find_by(:email => params[:user][:email]).update_attributes(:user_id => @user.id)
      end
      @users = User.order(sort_column + " " + sort_direction).includes(:account)
      @users = @users.paginate(:page => params[:page], :per_page => 25)
    end
  end
  
  def update
    @user = User.find_by(id: params[:id])
    puts @user.email
    if @user.update_attributes(user_params)
      flash[:notice] = "\"#{@user.email}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    # puts user_params[:email]
    # if Account.find_by(:email => params[:user][:email])
    #   Account.find_by(:email => params[:user][:email]).update_attributes(:user_id => @user.id)
    # end
    @users = User.order(sort_column + " " + sort_direction).includes(:account)
    @users = @users.paginate(:page => params[:page], :per_page => 25)
  end
  
  def show
    @users = User.find(params[:id])
  end
  
  private
  
  def sort_column
    related_columns = User.reflect_on_all_associations(:belongs_to).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = User.column_names.map {|a| "users.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "users.id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
  def user_params
     params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :phone_number)
  end
  
end