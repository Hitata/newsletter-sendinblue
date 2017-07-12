class Post < ActiveRecord::Base
  belongs_to :campaign
  
  scope :featured, -> {where(featured: true)}
  scope :others, -> {where(featured: false)}
end
