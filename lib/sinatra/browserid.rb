#!/usr/bin/env ruby

require "open-uri"
require 'json'
require 'url_safe_base64'
require 'jwt'
require "sinatra/base"
require 'sinatra/browserid/helpers'
require 'sinatra/browserid/template'

# This module provides an interface to verify a users email address
# with browserid.org.
module Sinatra
    module BrowserID
        def self.registered(app)
            app.helpers BrowserID::Helpers

            app.set :browserid_url, "https://broker.portier.io"
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
                  public_key_jwks = JSON.parse(URI.parse(URI.escape(settings.browserid_url + '/jwks.json')).read)
                  public_key = OpenSSL::PKey::RSA.new
                  public_key.e = OpenSSL::BN.new UrlSafeBase64.decode64(public_key_jwks["keys"][0]["e"]), 2 
                  public_key.n = OpenSSL::BN.new UrlSafeBase64.decode64(public_key_jwks["keys"][0]["n"]), 2
                  
                  id_token = JWT.decode params[:id_token], public_key, true, { :algorithm => 'RS256' }
                  id_token = id_token[0]
                  # 4. Needs to make sure token is still valid
                  if (id_token["iss"] == settings.browserid_url &&
                      id_token["aud"] == request.base_url.chomp('/') &&        
                      id_token["exp"] > Time.now.to_i &&
                      id_token["email_verified"] &&
                      id_token["nonce"] == session[:nonce])
                          session[:browserid_email] = id_token["email"]
                          session.delete(:nonce)
                          if session['redirect_url']
                            redirect session['redirect_url']
                          else
                            redirect "/"
                          end
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

