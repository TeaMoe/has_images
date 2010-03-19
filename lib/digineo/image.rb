class Digineo::Image < ActiveRecord::Base
  
  set_table_name :digineo_images
  self.cattr_accessor :has_images_options
  
  belongs_to :parentmodel, :polymorphic => true
  belongs_to :gallery,    :class_name => "Digineo::ImageGallery"
  belongs_to :image_type, :class_name => "Digineo::ImageType"  
  attr_accessor :file_url

  before_create :should_be_avatar?
  before_destroy :unset_avatar if :avatar
  
  named_scope :not_avatar, :conditions => "avatar=0"
  named_scope :without_gallery, :conditions => "gallery_id IS NULL"
  
  
  has_attached_file :file, :styles => {
     :thumb  => ["150x100", :jpg],
     :mini   => ["75x50",   :jpg],
     :medium => ["300x200", :jpg],
     :large  => ["640x480", :jpg],
     :huge   => ["800x600", :jpg],
     :square => ["200x200", :jpg] }, 
     :path   => ":rails_root/public/images/:parent/:short_id_partition/:parent_name_:style.:extension",
     :url    => "/images/:parent/:short_id_partition/:parent_name_:style.:extension"
  
  
  validates_attachment_presence :file, :unless => :file_url_provided?
  validates_presence_of :parentmodel
  before_validation :download_remote_file, :if => :file_url_provided?
 
  validates_presence_of :file_remote_url, :if => :file_url_provided?, :message => 'is invalid or inaccessible'
  
  def set_avatar
    parentmodel.avatar.unset_avatar if parentmodel.has_avatar?
    update_attribute(:avatar, true)
  end
  
  def unset_avatar
    update_attribute(:avatar, false)
  end
  
  private
  
  def should_be_avatar?
    self.avatar = !parentmodel.avatar
    true # returns true because it's called by before_create
  end
  
  def file_url_provided?
    !self.file_url.blank?
  end

  def file_url_provided?
    !self.file_url.blank?
  end
 
  def download_remote_file
    self.file = do_download_remote_file
    self.file_remote_url = file_url
  end
 
  def do_download_remote_file
    io = open(URI.parse(file_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
    rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
  
end
