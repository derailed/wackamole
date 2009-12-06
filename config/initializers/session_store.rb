# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wackamole_session',
  :secret      => 'c3c78df49b2b9b79a6de7bfefee1e3322e19c164e15395eb0f2760af82e1cc64ce2189594ed9cf4719ccf0384a98edd2d155cf4363233c5a3cd2cde9d03a5804'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
