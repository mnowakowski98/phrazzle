import 'package:phrazzle_central/phrazzle_central.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

final app = Router();

void main(List<String> arguments) async {
  final central = PhrazzleCentral();
  await serve(central.router.call, 'localhost', 3000);
}
