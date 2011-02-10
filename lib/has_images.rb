# HasImages

module HasImages
  def self.included(base)
    base.send :extend, ClassMethods    
  end

  module ClassMethods
    # adds has_images to model
    def has_images(options={})
      counter_cache = options.delete(:counter_cache) || false
      # eval is not always evil ;)
      # we generate a Digineo::Model::Image clase to store the given paperclip configuration in it  
      eval <<-EOF
        module Digineo::#{self.name} 
          class Digineo::#{self.name}::Image < Digineo::Image
             has_attached_file :file, #{options.inspect}
             belongs_to :parentmodel, :polymorphic => true, :counter_cache => #{counter_cache.inspect}
          end
        end
      EOF
      
      has_many :images, :as => :parentmodel, :dependent => :destroy, :order => 'id ASC', :class_name => "Digineo::#{self.name}::Image"
      has_one  :avatar, :as => :parentmodel, :conditions => 'avatar=1', :class_name => "Digineo::#{self.name}::Image"      
      has_many :galleries, :as => :parentmodel, :dependent => :destroy, :class_name => 'Digineo::ImageGallery'            
      
      named_scope :with_avatar, :include => :avatar
      
      send :include, InstanceMethods 
    end
  end

  module InstanceMethods
    
    # returns all images that are not set as avatar
    def more_images
       images.not_avatar
    end
    
    # returns all images without gallery
    def images_without_gallery
      images.without_gallery
    end
    
    # does this model have any images,  that are not set as avatar?
    def has_more_images?
      images.not_avatar.any?
    end
    
    def galleries?
      galleries.any?
    end
    
    def find_or_create_gallery(name)
      galleries.find_or_create_by_name(name)
    end
    
    
    def create_image_by_url(url, image_type = nil)
      images.create!(:file_url => url, :image_type => image_type)
    end
  end
end
