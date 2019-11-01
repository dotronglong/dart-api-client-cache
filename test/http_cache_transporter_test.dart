import 'dart:async';
import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:api_client_cache/api_client_cache.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockTransporter extends Mock implements Transporter {}

class MockResponse extends Mock implements Response {}

void main() {
  String url = "some-url";
  Map<String, String> headers = {"content-type": "application/json"};
  String body = '{"name":"John"}';

  test('cache response for 5 seconds', () async {
    MockResponse mockResponse = MockResponse();
    when(mockResponse.statusCode).thenReturn(200);

    MockTransporter mockTransporter = MockTransporter();
    when(mockTransporter.get(url, headers: headers))
        .thenAnswer((_) => Future.value(mockResponse));

    HttpCacheTransporter transporter =
        HttpCacheTransporter(expiresIn: 5000, transporter: mockTransporter);
    Response response = await transporter.get(url, headers: headers);
    verify(mockTransporter.get(url, headers: headers))
        .called(1); // only call once
    expect(response.statusCode, 200);

    sleep(Duration(seconds: 2));
    response = await transporter.get(url, headers: headers);
    expect(response.statusCode, 200);
    verifyNever(mockTransporter.get(url, headers: headers)); // no calls

    sleep(Duration(seconds: 4));
    response = await transporter.get(url, headers: headers);
    expect(response.statusCode, 200);
    verify(mockTransporter.get(url, headers: headers))
        .called(1); // invalidate cache
  });

  test('only allow to cache GET request', () async {
    MockResponse mockResponse = MockResponse();
    when(mockResponse.statusCode).thenReturn(200);

    MockTransporter mockTransporter = MockTransporter();
    when(mockTransporter.post(url, headers: headers, body: body))
        .thenAnswer((_) => Future.value(mockResponse));

    HttpCacheTransporter transporter = HttpCacheTransporter(
        expiresIn: 5000, onlyGET: true, transporter: mockTransporter);
    Response response =
        await transporter.post(url, headers: headers, body: body);
    verify(mockTransporter.post(url, headers: headers, body: body)).called(1);
    expect(response.statusCode, 200);

    sleep(Duration(seconds: 2));
    response = await transporter.post(url, headers: headers, body: body);
    expect(response.statusCode, 200);
    verify(mockTransporter.post(url, headers: headers, body: body))
        .called(1); // no cache
  });
}
