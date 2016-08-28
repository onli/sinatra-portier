module Sinatra
  module BrowserID
    module Helpers
      # Returns true if the current user has logged in and presented
      # a valid assertion.
      def authorized?
        ! session[:browserid_email].nil?
      end

      # If the current user is not logged in, redirects to a login
      # page. Override the login page by setting the Sinatra
      # option <tt>:browserid_login_url</tt>.
      def authorize!
        session[:authorize_redirect_url] = request.url
        login_url = settings.browserid_login_url
        redirect login_url unless authorized?
      end

      # Logs out the current user.
      def logout!
        session[:browserid_email] = nil
      end

      # Returns the BrowserID verified email address, or nil if the
      # user is not logged in.
      def authorized_email
        session[:browserid_email]
      end

      # Returns the HTML to render the Persona login form.
      # Optionally takes a URL parameter for where the user should
      # be redirected to after the assert POST back.
      def render_login_button(redirect_url = nil)
        if session[:authorize_redirect_url]
          redirect_url = session[:authorize_redirect_url]
          session[:authorize_redirect_url] = nil
        end
        redirect_url ||= request.url
        session['redirect_url'] = redirect_url

        template = ERB.new(Templates::LOGIN_BUTTON)
        template.result(binding)
      end
    end # module Helpers
  end
end

