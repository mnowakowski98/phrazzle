import 'package:phrazzle_central/phrazzle_central.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

final app = Router();

void main(List<String> arguments) async {
  final cascade = Cascade()
      // .add(
      //   webSocketHandler((websocket, _) {
      //     print('Got a websocket connection');
      //   }),
      // )
      .add(PhrazzleCentral().router.call);
  await serve(cascade.handler, 'localhost', 3000);
}
