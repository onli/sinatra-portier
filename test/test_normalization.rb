require 'minitest/autorun'
require 'sinatra/portier.rb'


class NormalizationTest < Minitest::Test
    include Sinatra::BrowserID::Helpers
    def test_valid
        assert_equal("example.foo+bar@example.com", normalize_email("example.foo+bar@example.com"))
        assert_equal("example.foo+bar@example.com", normalize_email("EXAMPLE.FOO+BAR@EXAMPLE.COM"))
        assert_equal("björn@xn--gteborg-90a.test", normalize_email("BJÖRN@göteborg.test"))
        assert_equal("i̇ⅲ@xn--iiii-qwc.example", normalize_email("İⅢ@İⅢ.example"))
    end

    def test_invalid
        assert_raises("ArgumentError") { 
            normalize_email("foo")
        }
        assert_raises("ArgumentError") { 
            normalize_email("foo@")
        }
        assert_raises("ArgumentError") {     
            normalize_email("@foo.example")
        }
        assert_raises("ArgumentError") { 
            normalize_email("foo@127.0.0.1")
        }
        assert_raises("ArgumentError") { 
            normalize_email("foo@[::1]")
        }
    end
end
