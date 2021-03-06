class Category < ActiveRecord::Base
  validates_presence_of :name

  has_and_belongs_to_many :wine_sizes
  belongs_to :image

  has_many :categories, :class_name=> "Category", :foreign_key => :parent_id
  belongs_to :parent, :class_name => "Category", :foreign_key => :parent_id

  has_many :categorizations, :dependent => :destroy
  scope :friendly_identifier_wines, -> {where(friendly_identifier: %w{white-wines red-wine rose-wine})}

  has_many :products, :through => :categorizations do
    def on_offer
      find(:all, :conditions => ["products.discount > ? AND active = ?", 0, true], :limit => 5, :order => "RAND()")
    end

    def at_the_night
      #find(:all, :conditions => ["HOUR(products.date) BETWEEN 17 AND 24"], :limit => 5, :order => "RAND()")
      find(:all, :conditions => ["HOUR(products.date) BETWEEN 17 AND 24"], :limit => 20, :order => "products.date")
    end

    def regions
      find(:all, :select => ["region_id"], :group => :region_id, :conditions => ["region_id IS NOT NULL OR region_id <> ''"]).inject([]) { |all_regions, product| all_regions << product.region }.compact
    end

    def producers
      find(:all, :select => ["producer_id"], :group => :producer_id, :conditions => ["producer_id IS NOT NULL OR producer_id <> ''"]).inject([]) { |all_producers, product| all_producers << product.producer }.compact
    end

    def grapes
      find(:all, :select => ["products.id"], :include => [:grapes], :order => "grapes.name ASC", :group => "grapes.id").inject([]) { |all_grapes, product| all_grapes << product.grapes }.flatten
    end

    def on_suggested
      find(:all, :conditions => ["products.discount > ? AND products.raccomanded = ? AND active = ?", 0, true, true], :limit => 2, :order => "RAND()")
    end
  end

  friendly_identifier :name

  acts_as_nested_set

  def reviews
    Review.find(:all, :conditions => ["reviews.reviewer_id IN (?) AND reviews.reviewer_type = ? AND publish = ?", self.products.collect(&:id), "Product",true], :limit => 5, :order => "reviews.created_at DESC")
  end

  def is_root?
    self.parent_id.blank?
  end

  def name_short(len)
    len ||= 20
    name.length >= len ? name[0,len] + " ..." : name
  end

  def layout_search_from_root
    root.layout_search
  end

  def title_formatted
    title.blank? ? name : title
  end

  def leaf?
    return if self.rgt - self.lft == 1
    return false
  end

  def show_errors
    return "- " + self.errors.full_messages.join("<br />- ")
  end

  def all_children
    child = []
    all_categories = Category.find(:all, :conditions => ["parent_id = ?", self.id])
    child << self.id 
    all_categories.each do |c|
      child << c.id 
    end

    return child
  end

  def all_products
    tmp = []
    products.each {|t| tmp << t unless tmp.include? t}
    for category in all_children
      for product in category.products
        tmp << product unless tmp.include? product
      end
    end
    return tmp
  end

  def all_products_ids
    tmp = []
    products.each {|t| tmp << t.id unless tmp.include? t.id}
    for cat in all_children
      category = Category.find(cat)
      for product in category.products
        tmp << product.id unless tmp.include? product.id
      end
    end
    return tmp
  end

  def self.tree(categories, parent, product)
    data = Array.new

    categories.each do |category|
      checked = product ? product.categories.include?(category) : false
      if !category.leaf?
        if data.empty?
          data =   [{:text  =>  category.name, :id  => category.id, :leaf  => false, :checked => checked, :children => self.tree(category.children, category, product) }]
        else
          data.concat([{:text  =>  category.name, :id  => category.id, :leaf  => false, :checked => checked, :children => self.tree(category.children, category, product)}])
        end
      else
        data.concat([{:text => category.name, :id => category.id, :cls => "folder", :checked => checked, :leaf => false, :children => []}])
      end
    end
    return data
  end
end

