class User < ActiveRecord::Base
  has_secure_password
  has_many :quotes
  has_many :favourites
end