import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_libsql_hack/drift_libsql.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:google_cloud/google_cloud.dart';
import 'package:google_cloud_shelf/google_cloud_shelf.dart';

import 'package:phrazzle_central/database.dart' show AppDatabase;

import 'package:phrazzle_central/routes/games.dart';
import 'package:phrazzle_central/routes/users.dart';
import 'package:phrazzle_central/routes/players.dart';

import 'package:phrazzle_central/stores/drift_player_store.dart';
import 'package:phrazzle_central/stores/json_game_store.dart';
import 'package:phrazzle_central/stores/drift_user_store.dart';

final app = Router();

void main(List<String> arguments) async {
  final tryCloud = bool.tryParse(const String.fromEnvironment('TRY_CLOUD')) ?? true;

  String? googleCloudProjectId;
  if (tryCloud) {
    try {
      googleCloudProjectId = await projectIdFromMetadataServer();
    } on MetadataServerException {
      print('Unable to determine cloud project');
    }
  }

  final isRunningOnCloud = tryCloud == true && googleCloudProjectId != null;

  QueryExecutor? executor;

  const databaseUrlKey = 'DATABASE_URL';
  const databaseTokenKey = 'DATABASE_TOKEN';
  final databaseUrl = Platform.environment[databaseUrlKey] ?? const String.fromEnvironment(databaseUrlKey, defaultValue: 'libsql://phrazzledev-nowakowskim.aws-us-east-1.turso.io');
  final databaseToken = Platform.environment[databaseTokenKey] ?? const String.fromEnvironment(databaseTokenKey);

  const libDirectoryPathKey = 'LIB_DIRECTORY_PATH';
  const libDirectoryPath = String.fromEnvironment(libDirectoryPathKey);

  if (databaseUrl.isNotEmpty) {
    executor = DriftLibsqlDatabase(
      databaseUrl,
      libDirectoryPath,
      authToken: databaseToken.isNotEmpty ? databaseToken : null,
      readYourWrites: true,
      syncIntervalSeconds: 3,
    );
  }

  final database = AppDatabase(executor);
  
  final gameStore = JsonGameStore('./store/');
  final userStore = DriftUserStore(database);
  final playerStore = DriftPlayerStore(database);

  final cascade = Cascade()
    .add(Games(gameStore, playerStore).router.call)
    .add(Users(userStore).router.call)
    .add(Players(gameStore, playerStore, userStore).router.call)
    .add((Request req) {
      final urlString = req.url.toString();
      if (urlString != 'healthz' && urlString != 'health') return Response.notFound(null);
      return Response.ok(jsonEncode({'status': 'healthy'}), headers: {'content-type': 'application/json'});
    });

  final pipeline = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(createLoggingMiddleware(projectId: googleCloudProjectId))
      .addHandler(cascade.handler);

  if (isRunningOnCloud) {
    await serveHandler(pipeline);
  } else {
    const portKey = 'PORT';
    final port =
        int.tryParse(
          Platform.environment[portKey] ?? String.fromEnvironment(portKey),
        ) ??
        80;
    print('Serving locally on $port');
    await serve(pipeline, InternetAddress.anyIPv4, port);
  }
}
