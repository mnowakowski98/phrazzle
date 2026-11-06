import 'dart:convert';
import 'dart:io';

import 'package:phrazzle_central/stores/json_game_store.dart';
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

import 'package:phrazzle_central/stores/game_store.dart';
import 'package:phrazzle_central/stores/drift_user_store.dart';
import 'package:phrazzle_central/stores/player_store.dart';

final app = Router();

void main(List<String> arguments) async {
  String? googleCloudProjectId;
  try {
    googleCloudProjectId = await projectIdFromMetadataServer();
  } on MetadataServerException {
    print('Unable to determine cloud project');
  }
  
  // final gameStore = GameStore();
  final gameStore = JsonGameStore('./store/');
  final userStore = DriftUserStore(AppDatabase());
  final playerStore = PlayerStore();

  final cascade = Cascade()
    .add(Games(gameStore, playerStore).router.call)
    .add(Users(userStore).router.call)
    .add(Players(playerStore, userStore).router.call)
    .add((Request req) {
      final urlString = req.url.toString();
      if (urlString != 'healthz' && urlString != 'health') return Response.notFound(null);
      return Response.ok(jsonEncode({'status': 'healthy'}), headers: {'content-type': 'application/json'});
    });

  final pipeline = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(createLoggingMiddleware(projectId: googleCloudProjectId))
      .addHandler(cascade.handler);

  if (googleCloudProjectId != null) {
    await serveHandler(pipeline);
  } else {
    final port = int.tryParse(String.fromEnvironment('PORT')) ?? 80;
    print('Serving locally on $port');
    await serve(pipeline, InternetAddress.anyIPv4, port);
  }
}
