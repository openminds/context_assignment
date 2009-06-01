class Person < ActiveRecord::Base
  attr_accessible :name, :first_name
  attr_accessible :name, :first_name, :is_admin, :context => :backoffice
  attr_accessible :api_key, :context => :api
end