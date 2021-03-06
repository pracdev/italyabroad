 class Site::BlogController < ApplicationController
  layout "site"
  before_filter :store_comment, :only => :comment, :method => :post
#  before_filter :site_login_required, :only => :comment
  def index

    per_page = 25
    if params[:category] == 'search_blog_post'
      posts = Post.where("name like '%#{params[:text]}%' or friendly_identifier like '%#{params[:text]}%'")  
    elsif params[:tag_id]
      @tag = Tag.find(params[:tag_id])

       posts = @tag.posts.where(["blog_type_id = ?", 1]).order("created_at DESC").paginate(:page => params[:page], :per_page => per_page)

    elsif params[:year].blank? && params[:month].blank?
      posts = Post.where(["blog_type_id = ?", 1]).order("created_at DESC").paginate(:page => params[:page], :per_page => per_page)
    else
      @year = params[:year].to_i
      @month = params[:month].to_i
      begin_of_the_month = "1/#{@month}/#{@year}".to_time.utc
      end_of_the_month = begin_of_the_month.end_of_month.to_time.utc
     posts = Post.where("blog_type_id = ? AND created_at >= ? AND created_at <= ?", 1, begin_of_the_month.to_s(:db), end_of_the_month.to_s(:db)).paginate(:page => params[:page], :per_page => per_page)
    
    end
    @posts = posts
    
    respond_to do |wants|
      wants.html
      wants.xml { render :layout => false }
    end
  end

  def show
    store_location
    if params[:friendly_identifier]
      post = Post.find(params[:friendly_identifier])
    else
      post = Post.find(params[:id])
    end
    @post = post
    unless @post
      redirect_to "/404"
    else
      @post.count_view if @post
      @comments = @post.comments.where(reply_id: nil,public: true).paginate(:page => params[:page], :per_page => 5).order("created_at DESC")
    end

  end

  def comment
    @post = Post.find(params[:id])
    comment_public = current_user ? current_user.admin? : false  
    @comment = Comment.new(
      :name => session[:name],
      :description => session[:description],
      :captcha => session[:captcha],
      :captcha_key => session[:captcha_key],
      :mail_check => session[:mail_check],
      :reply_id => session[:reply_id],
      :public => comment_public
    )
    @comment.post = @post if !session[:reply_id].present?
    @comment.email = current_user.email
    @comment.user_id = current_user.id
    if verify_recaptcha(model: @comment)  and @comment.save
      Notifier.comment(@comment,current_user).deliver
      flash[:notice] = "comment is successfully posted"
    elsif session[:reply_id].present?  and @comment.save
      Notifier.reply_comment(@comment,@comment.comment.user).deliver
      flash[:notice] = "comment is successfully posted"      
    else
      flash[:notice] = @comment.show_errors
     # render :action => :show
    end
      redirect_to blog_path(@post.friendly_identifier)
  end



  protected
  def store_comment

    if params[:comment]
      session[:name] = params[:comment][:name]
      session[:description] = params[:comment][:description]
      session[:captcha] = params[:comment][:captcha]
      session[:captcha_key] = params[:comment][:captcha_key]
      session[:mail_check] = params[:comment][:mail_check]
      session[:reply_id] = params[:comment][:reply_id]
    end
  end

  def check_mail_list(post, user)
    @post = Post.find(post)
    no_of_comment = @post.comments.count
    if no_of_comment == 1 
      return true
    else
      p no_of_comment

      @comments = (@post.comments).find(:all, :conditions =>[' mail_check = ?',true])
      p "********tyty***************************"
      p @comments.count
      p "**********ytyy**************************"
      for comment in @comments
        Notifier.comment(comment,user).deliver
      end
    end
  end

end

