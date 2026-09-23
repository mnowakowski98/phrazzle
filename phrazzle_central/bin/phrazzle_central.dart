import 'package:phrazzle_central/phrazzle_central.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

final app = Router();

void main(List<String> arguments) async {
  final cascade = Cascade().add(PhrazzleCentral().router.call);

  final pipeline = Pipeline()
      .addMiddleware(corsHeaders())
      .addHandler(cascade.handler);
  await serve(pipeline, 'localhost', 3000);
}
