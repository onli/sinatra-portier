#!/usr/bin/env ruby

require "open-uri"
require 'json/jwt'
require 'json/jwk'
require "sinatra/base"
require 'sinatra/browserid/helpers'
require 'sinatra/browserid/template'

# This module provides an interface to verify a users email address
# with browserid.org.
module Sinatra
    module BrowserID
        def self.registered(app)
            app.helpers BrowserID::Helpers

            app.set :browserid_url, "https://laoidc.herokuapp.com"
            app.set :browserid_login_button, :red
            app.set :browserid_login_url, "/_browserid_login"

            app.get '/_browserid_login' do
                # TODO(petef): render a page that initiates login without
                # waiting for a user click.
                render_login_button
            end

          app.post '/_browserid_assert' do
              begin
                  # 3. Server checks signature
                  # for that, fetch the public key from the LA instance (TODO: Do that beforehand for trusted instances, and generally cache the key)
                  public_key_jwks = URI.parse(URI.escape(settings.browserid_url + '/jwks.json')).read
                  public_key = JSON::JWK.new(public_key_jwks)

                  # TODO: we are skipping verification here, because the JWT gem is throwing an error, calling verify! on a string, which of course does not have this method. This is possibly a bug in the JWT module and needs to be fixed, or signature verification done manually
                  id_token = JSON::JWT.decode params[:id_token], :skip_verification
                  # 4. Needs to make sure token is still valid
                  if (# id_token.verify! public_key  
                      id_token[:iss] == settings.browserid_url &&
                      id_token[:aud] == request.base_url.chomp('/') &&        
                      # id_token[:sub].present? &&  TODO: Decide whether we really can skip these two tests
                      # id_token[:nonce] == expected_nonce &&
                      id_token[:exp] > Time.now.to_i)
                          session[:browserid_email] = id_token[:email_verified]
                          redirect "/"
                  end
              rescue OpenURI::HTTPError => e
                  puts "could not validate token: " + e.to_s
              end
              halt 403
              
            end
        end # def self.registered
    end # module BrowserID
    register BrowserID
end # module Sinatra

