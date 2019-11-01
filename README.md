# api_client_cache
[![Build Status](https://travis-ci.org/dotronglong/dart-api-client-cache.svg?branch=master)](https://travis-ci.org/dotronglong/dart-api-client-cache)

A HTTP Cache transporter for `api_client`

### How to use

```dart
import 'package:api_client/api_client.dart';
import 'package:api_client_cache/api_client_cache.dart';

final Spec spec = Spec(
        transporter: HttpCacheTransporter(expiresIn: 15000)
        // other configuration
      );
```

### Arguments

- `onlyGET` apply caching for `GET` request only (default is `true`)
- `expiresIn` set time to live (in milliseconds) for cache entry (default is `15000`)
- `transporter` set custom transporter rather than `Transporter.factory()`
