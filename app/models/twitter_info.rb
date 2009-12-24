class TwitterInfo < ActiveRecord::Base
  belongs_to :element #Twitter details are stored on a per board basis
  validates_presence_of :username, :password
end
