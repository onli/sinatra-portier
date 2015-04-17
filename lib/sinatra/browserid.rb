#!/usr/bin/env ruby

require "json"
require "net/https"
require "sinatra/base"
require 'sinatra/browserid/helpers'
require 'sinatra/browserid/template'

# This module provides an interface to verify a users email address
# with browserid.org.
module Sinatra
  module BrowserID
    def self.registered(app)
      app.helpers BrowserID::Helpers

      app.set :browserid_url, "https://login.persona.org"
      app.set :browserid_login_button, :red
      app.set :browserid_login_url, "/_browserid_login"

      app.get '/_browserid_login' do
        # TODO(petef): render a page that initiates login without
        # waiting for a user click.
        render_login_button
      end

      app.post '/_browserid_assert' do
        # TODO(petef): do verification locally, without a callback
        audience = request.host_with_port
        bid_uri = URI.parse(settings.browserid_url)
        http = Net::HTTP.new(bid_uri.host, bid_uri.port)
        http.use_ssl = true
        data = {
          "assertion" => params[:assertion],
          "audience" => audience,
        }
        data_str = data.collect { |k, v| "#{k}=#{v}" }.join("&")
        res = http.post("/verify", data_str)

        if res.code =~ /^2\d{2}$/
          verify = ::JSON.parse(res.body)
        else
          return
        end

        if verify["status"] != "okay"
          $stderr.puts "status was not OK. #{verify.inspect}"
          return
        end

        session[:browserid_email] = verify["email"]
        session[:browserid_expires] = verify["expires"].to_f / 1000

        redirect params[:redirect] || "/"
      end
    end # def self.registered
  end # module BrowserID
  register BrowserID
end # module Sinatra

