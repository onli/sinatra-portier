Sinatra plugin that allows authentication against portier, the successor for [Persona](https://login.persona.org/about). Like Persona, this lets you verify the email identity of a user.

To be a drop-in replacement, the code keeps using the browserid namespace.

---

To learn more, [read about portier](https://portier.github.io/).

Note that logins are not done from within a form on your site -- you provide a login form, and that will start up the login flow and redirect back to your main page.

How to get started:

```ruby
require 'sinatra/base'
require 'sinatra/browserid'

module MyApp < Sinatra::Base
    register Sinatra::BrowserID

    set :sessions, true

    get '/'
        if authorized?
            "Welcome, #{authorized_email}"
        else
            render_login_button
        end
    end

    get '/secure'
        authorize!                 # require a user be logged in

        email = authorized_email   # browserid email
        ...
    end

    get '/logout'
        logout!

        redirect '/'
    end
end
```

See the rdoc for more details on the helper functions.  For a functioning
example app, run <tt>rackup -p $PORT</tt> in the example directory.

Available sinatra settings:

 * <tt>:browserid_url</tt>: If you're using an alternate auth provider
  other than https://broker.portier.io
 * <tt>:browserid_login_url</tt>: URL users get redirected to when the
  <tt>authorize!</tt> helper is called and a user is not logged in
