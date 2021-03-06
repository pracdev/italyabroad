class Site::CustomersController < ApplicationController
  before_filter :site_login_required, :except => [:new, :create, :confirmation, :find, :request_new_password, :show,:update_default_pic]

  layout "site"

  # SSL is not required in these case
  #ssl_required :new, :create, :account, :order # if Rails.env == "production"

  def new
    @user = User.new
  end

  def show
    store_location
    @user = User.find(params[:id])
    @my_profile = (@user == current_user)
    #to show link You have new message in my profile page if there is unread msg
    @unread_msg = false
    if @my_profile and Message.find(:all,:conditions=>['user_id =? and read_or_not = ?',@user.id,false]).size > 0
      @unread_msg = true
    end
    # end to show link You have new message
    respond_to do |format|
      if @user.type_id == 4
        format.html {render :action => :chef_profile}

      else
        format.html
      end
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
    unless params[:photo].nil?
      @photo = Photo.new(params[:photo])
      @photo.save
      @user.photo_id = @photo.id
    else
      set_photo_from_default(params[:kind],@user)
    end
    if params[:chef] and params[:chef].to_i == 4
      @user.type_id = 4
      @user.active = false
    else
      @user.type_id = 2
      @user.active = true
    end

    @user.provider = session[:omniauth][:provider] if session[:omniauth].present?
    #@user.activation_code = ActivePassword.new #Customers don't wont activations
    #if @user.valid_with_captcha?
    if  !params[:conditions].nil?
      if @user.save_obj(session[:omniauth])
        #.save_with_captcha
        Notifier.new_account_created(@user,AppConfig.admin_email).deliver
        flash[:title] = "Congratulations"
        flash[:message] = "Your account has been created, an email with your account details has been sent to #{@user.email}."
        if @user.type_id != 4
          self.current_user = User.authenticate(@user.login, @user.password_clean)
          #redirect_back_or_default(:action => :messages)
        elsif @user.type_id == 4
          flash[:alert] = "The profile will be reviewed by a member of our team before being published"
          #  flash[:notice] = "The profile will be reviewed by a member of our team before being published"

        end
        #redirect_to root_path
        #New added
        if (!session[:return_to].blank? && session[:return_to] == '/cart/gift_options') || @cart.try(:items).try(:size).to_i > 0
          return_to = "/cart/gift_options"
          session[:return_to] = ""
          redirect_to return_to and return
        else
          redirect_to root_path
        end
        #New Added
      else
        flash[:error] = @user.show_errors
        render :action => :new
      end
      #redirect_back_or_default(root_url)
    else
      flash[:error] = @user.show_errors
      flash[:error] +=  ('<br />' + "You have to accept the terms and conditions").html_safe()
      render :action => :new
    end
    #else
    #  flash[:notice] = @user.show_errors
    #  if params[:conditions].nil?
    #    flash[:notice] +=  ('<br />' + "You have to accept the terms and conditions").html_safe()
    #  end
    #  render :action => :new
    #end
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
            Notifier.account_created.deliver(@user)
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
    unless @user.photo_id.nil? or @user.photo_id.blank?
      @photo = Photo.find_by_id(current_user.photo_id)
    end

    redirect_to :controller => :base, :action => :index if @user.nil?

  end

  def update_default_pic
    #  @user = current_user
    # set_photo_from_default(params[:kind],@user)

    render :layout => false
  end

  def update 
    
    @user = current_user
    old_mail = @user.email
    unless params[:photo].nil?
      @photo = Photo.new(params[:photo])
      @photo.save
      @user.photo_id = @photo.id
      @user.photo_default = ""
    else
      set_photo_from_default(params[:kind],@user)
    end

    if params[:chef].to_i == 4
      @user.type_id = 4
      @user.active = false
    elsif (params[:chef].to_i != 4 and @user.type_id.to_i != 1)
      @user.type_id = 2
      @user.active = true
    end



    # @user.set_photo_from_upload(params[:photo])
    if @user.update_attributes(params[:user])
      Notifier.account_data(User.find(@user.id)).deliver unless(params[:user][:password].blank?)
      
      flash[:title] = "Congratulations"
      flash[:message] = "Your account has been update, you will now receive an email"
      #   render :action => :messages
      if params[:return_to_url] == 'true'
        redirect_to '/checkouts'
      else
        redirect_to '/my-account'
      end
      #  redirect_to root_url
    else

      flash[:notice] = @user.show_errors
      render :action => :account
    end
  end

  def find
    @user = User.find_by_login(params[:user][:login])
    @user = User.find_by_email(params[:user][:email]) if @user.nil?
    if @user
      Notifier.account_data(@user).deliver
      flash[:title] = "Mail Sent"
      flash[:msg] = "An email with the password has been sent to the registered address"
    else
      flash[:title] = "Sorry"
      flash[:notice] = "Sorry We couldn't find your account, please contact us or create a new account"
    end
    redirect_to request_new_password_path
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

  def send_message
    @message = Message.new(:name=>params[:name],:user_id=>params[:user_id],:send_by_id=>params[:send_by_id])
    if @message.save
      Notifier.new_message_received(params[:name],User.find(params[:user_id]),User.find(params[:send_by_id])).deliver
      redirect_to customer_path(params[:user_id])
    else
      flash[:notice] = @message.show_errors
      redirect_to customer_path(params[:user_id])
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

  def set_photo_from_default(kind,user)
    case kind
      when "1"
        image = AppConfig.avatar_1
      when "a"
        image = AppConfig.avatar_2
      when "b"
        image = AppConfig.avatar_3
      when "c"
        image = AppConfig.avatar_4
      when "d"
        image = AppConfig.avatar_5
      when "e"
        image = AppConfig.avatar_6
    end


    if image
      user.photo_id = ""
      user.photo_default = image
      # @photo = Photo.new
      # @photo.image_file = image
      # user.photo = image
      # @photo.save
      # user.photo_id = @photo.id

      begin
        #  user.photo.destroy if user.photo
      rescue => e
        logger.info "Unexpected error when delete photo #{self.photo.id} \n #{e.inspect}"
      end
      # user.photo_id = nil
      #  user.save
    end

  end


  def destroy

    user = User.regulars.find(params[:id])
    current_user.forget_me if logged_in? 
    cookies.delete :auth_token
    reset_session
    user.destroy
    current_user = nil 
  end

end

