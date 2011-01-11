# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :namespace   => 'sessions',
  :key         => '_trunk_session',
  :secret      => '247990b07edc14f0a115dcbc04483a2c22ced37c5ca1362e06134021d0631be7783172368f1e25a7aacc6ca418c97693752278ee0df43f469a95875d6a2d5e69'
}

require 'action_controller/session/dalli_store'
ActionController::Base.session_store = :dalli_store

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
