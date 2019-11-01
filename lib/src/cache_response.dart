import 'package:api_client/api_client.dart';

class CacheResponse {
  final Response response;
  final int expiresAt;

  CacheResponse(this.response, this.expiresAt);
}
