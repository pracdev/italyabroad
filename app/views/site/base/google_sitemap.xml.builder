xml.instruct!
 
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
  xml.url do
    xml.loc         "http://www.italyabroad.com/"
    xml.lastmod     w3c_date(Time.now)
    xml.changefreq  "always"
  end
  
  @products.each do |product|
    xml.url do
      xml.loc         url_for(:only_path => false, :controller => 'site/products', :action => 'show', :id => product.friendly_identifier)
      xml.lastmod     w3c_date(product.updated_at)
      xml.changefreq  "daily"
      xml.priority    0.8
    end
  end
 
  @posts.each do |post|
    xml.url do
      xml.loc         url_for(:only_path => false, :controller => 'site/blog', :action => 'show', :id => post)
      xml.lastmod     w3c_date(post.created_at)
      xml.changefreq  "weekly"
      xml.priority    0.6
    end
  end
 
end
