class Site::CustomersController < ApplicationController
  before_filter :site_login_required, :except => [:new, :create, :confirmation, :find, :request_new_password, :show]

  layout "site"

  ssl_required :new, :create, :account, :order if RAILS_ENV == "production"

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @my_profile = @user == current_user
    
    respond_to do |format|
      format.html
    end
  end

  def print_invoice
    @order = Order.find(params[:id])
    if @order.user != current_user
      redirect_to :controller => :base, :action => :index
    else
      make_and_send_pdf("site/customers/print_invoice", "Italyabroad_Invoice_#{@order.id}.pdf")
    end
  end
  
  def print_tasting
    @order = Order.find(params[:id])
    if @order.user != current_user
      redirect_to :controller => :base, :action => :index
    else
      @tasting_notes = true
      make_and_send_pdf("site/customers/print_tasting", "Italyabroad_Tasting_Notes_#{@order.id}.pdf")
    end
  end
  
  def create
    @user = User.new(params[:user])
    @user.type_id = 2
    @user.active = true
    #@user.activation_code = ActivePassword.new #Customers don't wont activations
    if @user.save
      flash[:title] = "Congratulations"
      flash[:message] = "Your account has been created, an email with your account details has been sent to #{@user.email}."
      self.current_user = User.authenticate(@user.login, @user.password_clean)
#      redirect_back_or_default(:action => :messages)
      redirect_back_or_default(root_url)
    else
      flash[:notice] = @user.show_errors
      render :action => :new
    end
  end
  
  def confirmation
    @user = User.find_by_id(params[:id])
    
    if @user
      if @user.activation_code == params[:code]
        if @user.active
          flash[:title] = "Congratulations"
          flash[:message] = "Your account has been activated"
        else
          if @user.update_attributes({:active => true})
            Notifier.deliver_account_created(@user)
            self.current_user = User.authenticate(@user.login, @user.password_clean)
            flash[:title] = "Congratulations"
            flash[:message] = "Your account has been created, an email with your account details has been sent to #{@user.email}."
          else
            flash[:title] = "Sorry"
            flash[:message] = "We are experiencing some problems, please try again later or contact us."
          end
        end
      else
        flash[:title] = "Sorry"
        flash[:message] = "Your details are incorrect, please try again or contact us."
      end
    else
      flash[:title] = "Sorry"
      flash[:message] = "We couldn't find your account, please contact us or create a new account."
    end
    
    render :action => :messages
  end
  
  def account
    @user = current_user
    redirect_to :controller => :base, :action => :index if @user.nil?
  end

  def update_default_pic
    @user = current_user
    @user.set_photo_from_default(params[:kind])
    render :layout => false
  end
  
  def update
    @user = current_user
    old_mail = @user.email

    @user.set_photo_from_upload(params[:photo])
    if @user.update_attributes(params[:user])
        Notifier.deliver_account_data(User.find(@user.id))
        flash[:title] = "Congratulations"
        flash[:message] = "Your account has been update, you will now receive an email"
      render :action => :messages
    else
      flash[:notice] = @user.show_errors
      render :action => :account
    end
  end
  
  def find
    @user = User.find_by_login(params[:user][:login])
    @user = User.find_by_email(params[:user][:email]) if @user.nil?
    if @user
      Notifier.deliver_account_data(@user) 
      flash[:title] = "Mail Sent"
      flash[:message] = "Your login details have been sent to #{@user.email}."
    else
      flash[:title] = "Sorry"
      flash[:message] = "We couldn't find your account, please contact us or create a new account"
    end
    render :action => :messages
  end

  def follow
    follower = User.find(params[:user_id])
    follower.followers.create(:follower_id => current_user.id) if follower && !follower.followed_by?(current_user)
    
    respond_to do |format|
      if follower
        format.html { redirect_to(customer_path(follower)) }
      else
        format.html { redirect_to(customer_path(current_user)) }
      end 
    end
  end
  
  def unfollow
    user = User.find(params[:user_id])
    follower = user.followers.find_by_follower_id(current_user.id)

    respond_to do |format|
      if user && follower
        follower_id = follower.follower_id
        follower.destroy
        format.html { redirect_to(customer_path(user)) }
      else
        format.html { redirect_to(customer_path(current_user)) }
      end 
    end
  end

  def request_new_password
    
    respond_to do |format|
      format.html
    end
  end

end
