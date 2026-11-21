import 'dart:convert';

import 'package:shelf/shelf.dart';

Response jsonResponse(Object object) => Response.ok(
  jsonEncode(object),
  headers: {'content-type': 'application/json'},
);
