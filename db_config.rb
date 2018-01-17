require 'pg'
require 'active_record'

options = {
  adapter: 'postgresql',
  database: 'quote_app'
}


ActiveRecord::Base.establish_connection(options)