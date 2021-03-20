require 'sinatra'
require 'sinatra/browserid'


register Sinatra::BrowserID

set :sessions, true
# Disabling origin-check is needed to make webkit-browsers like Chrome work. 
# Behind a proxy you will also need to disable :remote_token, regardless for which browser.
set :protection, except: [:http_origin] 
get '/' do
    if authorized?
        "Welcome, #{authorized_email}"
    else
        render_login_button
    end
end

get '/secure' do
    authorize!                 # require a user be logged in

    authorized_email   # browserid email
end

get '/logout' do
    logout!

    redirect '/'
end