module Sinatra
    module BrowserID
        module Templates
            LOGIN_BUTTON = <<-EOF
<form action="<%= settings.browserid_url %>/auth" method="POST">
      <input type=email name=login_hint placeholder="you@example.com" />
      <input type=hidden name=scope value="openid email" />
      <input type=hidden name=response_type value="id_token" />
      <input type=hidden name=response_mode value="form_post" />
      <input type=hidden name=client_id value="<%= request.base_url.chomp('/') %>" />
      <input type=hidden name=redirect_uri value="<%= url '/_browserid_assert' %>" />
      <input type=hidden name=nonce value="<%= nonce %>" />
      <input type=submit value="Log In" class="<%= settings.browserid_button_class %>" />
    </form>
EOF
        end
    end
end

