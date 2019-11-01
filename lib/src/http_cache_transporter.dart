import 'dart:async';
import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:crypto/crypto.dart';

import 'cache_response.dart';

class HttpCacheTransporter implements Transporter {
  Transporter _transporter = Transporter.factory();
  final Map<String, CacheResponse> _data = Map();
  final bool _onlyGET;
  final int _expiresIn;

  /// Creates a new HttpCacheTransporter
  ///
  /// onlyGET: only apply cache for GET method
  /// expiresIn: how long cache is expired in milliseconds
  /// transporter: use a custom transporter rather than Transporter.factory()
  HttpCacheTransporter(
      {bool onlyGET = true, int expiresIn = 15000, Transporter transporter})
      : this._onlyGET = onlyGET,
        this._expiresIn = expiresIn {
    if (transporter != null) this._transporter = transporter;
  }

  /// Generates a hash string as cache's key
  String _id(String method, String url, Map<String, String> headers, body) {
    String id = "${method}|${url}|";
    headers.forEach((k, v) {
      id = "$id$k:$v,";
    });
    id = body != null && body is String ? "$id|$body" : id;
    return md5.convert(utf8.encode(id)).toString();
  }

  Response _get(String id) {
    final CacheResponse cache = _data[id];
    if (cache != null &&
        DateTime.now().millisecondsSinceEpoch <= cache.expiresAt) {
      return cache.response;
    }
    return null;
  }

  void _put(String id, Response response) {
    _data[id] = CacheResponse(
        response, DateTime.now().millisecondsSinceEpoch + _expiresIn);
  }

  Future<Response> get(url, {Map<String, String> headers}) async {
    final String id = _id(Method.GET, url, headers, null);
    Response response = _get(id);
    if (response == null) {
      response = await _transporter.get(url, headers: headers);
      _put(id, response);
    }
    return response;
  }

  Future<Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    if (_onlyGET) {
      return _transporter.post(url,
          headers: headers, body: body, encoding: encoding);
    }
    final String id = _id(Method.POST, url, headers, body);
    Response response = _get(id);
    if (response == null) {
      response = await _transporter.post(url,
          headers: headers, body: body, encoding: encoding);
      _put(id, response);
    }
    return response;
  }

  Future<Response> put(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    if (_onlyGET) {
      return _transporter.put(url,
          headers: headers, body: body, encoding: encoding);
    }
    final String id = _id(Method.PUT, url, headers, body);
    Response response = _get(id);
    if (response == null) {
      response = await _transporter.put(url,
          headers: headers, body: body, encoding: encoding);
      _put(id, response);
    }
    return response;
  }

  Future<Response> patch(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    if (_onlyGET) {
      return _transporter.patch(url,
          headers: headers, body: body, encoding: encoding);
    }
    final String id = _id(Method.PATCH, url, headers, body);
    Response response = _get(id);
    if (response == null) {
      response = await _transporter.patch(url,
          headers: headers, body: body, encoding: encoding);
      _put(id, response);
    }
    return response;
  }

  Future<Response> delete(url, {Map<String, String> headers}) async {
    if (_onlyGET) {
      return _transporter.delete(url, headers: headers);
    }
    final String id = _id(Method.DELETE, url, headers, null);
    Response response = _get(id);
    if (response == null) {
      response = await _transporter.delete(url, headers: headers);
      _put(id, response);
    }
    return response;
  }
}
