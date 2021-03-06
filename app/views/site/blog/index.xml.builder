xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do

    xml.title       "Andrea's latest Blog Entry at italyabroad.com"
    xml.link        url_for :only_path => false, :controller => 'site/base'
    xml.pubDate     CGI.rfc1123_date @posts.first.updated_at if @posts.any?
    xml.description "Andrea's latest Blog Entry at italyabroad.com"

    @posts.each do |post|
      xml.item do
        xml.title       post.name
        xml.link        blog_url(post.id)
        # xml.description render :partial => "/site/templates/feed_post", :object => post
        xml.description post.description_short
        xml.pubDate     CGI.rfc1123_date post.updated_at
        xml.guid        blog_url(post.id)
        xml.author      "Andrea D'Ercole"
      end
    end

  end
end
