require File.dirname(__FILE__) + '/helper'

class OneSignalTest < MiniTest::Test

  def setup
    @api_key = "fake_api_123"
    @body = "fake body"
    @params = {foo: 'bar', widget: 'acme'}
    @opts = {auth_key: @api_key}
    @uri = URI.parse("https://www.example.com/foo/bar")
    @default_timeout = 30
  end

  def teardown
    OneSignal::OneSignal.api_key = nil
    OneSignal::OneSignal.open_timeout = @default_timeout
    OneSignal::OneSignal.read_timeout = @default_timeout
  end

  def build_mock_request(body: nil, auth_key: nil)
    request = mock()
    request.expects(:body=).with(body.to_json) unless body.nil?
    request.expects(:add_field).with("Content-Type", "application/json")
    request.expects(:add_field).with("Authorization", "Basic #{auth_key}")
    return request
  end

  def build_mock_http_object
    use_ssl = @uri.scheme == 'https'
    http = mock()
    http.expects(:use_ssl=).with(use_ssl)
    http.expects(:open_timeout=)
    http.expects(:read_timeout=)
    return http
  end

  def test_default_timeout
    assert_equal @default_timeout, OneSignal::OneSignal.open_timeout
    assert_equal @default_timeout, OneSignal::OneSignal.read_timeout
  end

  def test_setting_timeout
    open_timeout = OneSignal::OneSignal.open_timeout + 1
    read_timeout = OneSignal::OneSignal.read_timeout + 2
    OneSignal::OneSignal.open_timeout = open_timeout
    OneSignal::OneSignal.read_timeout = read_timeout

    assert_equal open_timeout, OneSignal::OneSignal.open_timeout
    assert_equal read_timeout, OneSignal::OneSignal.read_timeout
  end

  def test_http_object
    # test default timeout values
    http_object = OneSignal::OneSignal.http_object(uri: @uri)
    assert_equal @default_timeout, http_object.open_timeout
    assert_equal @default_timeout, http_object.read_timeout

    # change timeout values
    open_timeout = OneSignal::OneSignal.open_timeout + 1
    read_timeout = OneSignal::OneSignal.read_timeout + 2
    OneSignal::OneSignal.open_timeout = open_timeout
    OneSignal::OneSignal.read_timeout = read_timeout
    http_object = OneSignal::OneSignal.http_object(uri: @uri)

    assert_equal open_timeout, http_object.open_timeout
    assert_equal read_timeout, http_object.read_timeout
  end

  def test_send_post_request
    # test request creation
    request = build_mock_request(body: @body, auth_key: @api_key)
    Net::HTTP::Post.expects(:new).with(@uri.request_uri).returns(request)

    # test http object creation
    http = build_mock_http_object
    Net::HTTP.expects(:new).with(@uri.host, @uri.port).returns(http)

    # test send request
    response = mock()
    http.expects(:request).with(request).returns(response)

    assert_equal response, OneSignal::OneSignal.send_post_request(uri: @uri,
                                                                  body: @body,
                                                                  opts: @opts)
  end

  def test_send_delete_request
    expected_uri = @uri.clone
    expected_uri.query = URI.encode_www_form(@params)

    # test request creation
    request = build_mock_request(auth_key: @api_key)
    Net::HTTP::Delete.expects(:new).with(expected_uri.request_uri).returns(request)

    # test http object creation
    http = build_mock_http_object
    Net::HTTP.expects(:new).with(expected_uri.host, expected_uri.port).returns(http)

    # test send request
    response = mock()
    http.expects(:request).with(request).returns(response)

    assert_equal response, OneSignal::OneSignal.send_delete_request(uri: @uri,
                                                                    params: @params,
                                                                    opts: @opts)
  end

  def test_send_put_request
    # test request creation
    request = build_mock_request(body: @body, auth_key: @api_key)
    Net::HTTP::Put.expects(:new).with(@uri.request_uri).returns(request)

    # test http object creation
    http = build_mock_http_object
    Net::HTTP.expects(:new).with(@uri.host, @uri.port).returns(http)

    # test send request
    response = mock()
    http.expects(:request).with(request).returns(response)

    assert_equal response, OneSignal::OneSignal.send_put_request(uri: @uri,
                                                                 body: @body,
                                                                 opts: @opts)
  end

  def test_send_get_request
    expected_uri = @uri.clone
    expected_uri.query = URI.encode_www_form(@params)

    # test request creation
    request = build_mock_request(auth_key: @api_key)
    Net::HTTP::Get.expects(:new).with(expected_uri.request_uri).returns(request)

    # test http object creation
    http = build_mock_http_object
    Net::HTTP.expects(:new).with(expected_uri.host, expected_uri.port).returns(http)

    # test send request
    response = mock()
    http.expects(:request).with(request).returns(response)

    assert_equal response, OneSignal::OneSignal.send_get_request(uri: @uri,
                                                                 params: @params,
                                                                 opts: @opts)
  end

end
