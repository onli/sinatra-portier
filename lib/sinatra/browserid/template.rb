module Sinatra
  module BrowserID
    module Templates
      LOGIN_BUTTON = <<-EOF
<script src="<%= settings.browserid_url %>/include.js" type="text/javascript"></script>
<script type="text/javascript">
function _browserid_login() {
navigator.id.getVerifiedEmail(function(assertion) {
    if (assertion) {
        document.forms._browserid_assert.assertion.value = assertion;
        document.forms._browserid_assert.submit();
    } else {
        // TODO: handle failure case?
    }
});
}
</script>

<form name="_browserid_assert" action="<%= url '/_browserid_assert' %>" method="post">
<input type="hidden" name="redirect" value="<%= redirect_url %>">
<input type="hidden" name="assertion" value="">
</form>

<a href="#"><img src="<%= button_url %>" id="browserid_login_button" border=0 onClick="_browserid_login()" /></a>
EOF
    end
  end
end

