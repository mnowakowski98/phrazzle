import 'dart:convert';
import 'dart:io';

import 'package:google_cloud/google_cloud.dart';
import 'package:google_cloud_shelf/google_cloud_shelf.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:phrazzle_central/phrazzle_central.dart';

final app = Router();

void main(List<String> arguments) async {
  final forceLocal = bool.tryParse(String.fromEnvironment('FORCE_LOCAL')) ?? false;

  String? projectId;
  try {
    projectId = await computeProjectId();
  } on MetadataServerException {
    print('Unable to determine cloud project');
  }

  final cascade = Cascade().add(PhrazzleCentral().router.call).add((Request req) {
    if (req.url.toString() != 'healthz') return Response.notFound(null);
    return Response.ok(jsonEncode({'status': 'healthy'}), headers: {'content-type': 'application/json'});
  });

  final pipeline = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(createLoggingMiddleware(projectId: projectId))
      .addHandler(cascade.handler);

  if (projectId != null && forceLocal == false) {
    await serveHandler(pipeline);
  } else {
    final port = int.tryParse(String.fromEnvironment('PORT')) ?? 80;
    print('Serving locally on $port');
    await serve(pipeline, InternetAddress.anyIPv4, port);
  }
}
