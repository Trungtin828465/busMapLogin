import 'package:fluro/fluro.dart';  // Import Fluro
import 'package:busmap/screens/HomePage.dart';
import 'package:busmap/screens/SelectRoute.dart';




class FluroRouterConfig {
  static final FluroRouter router = FluroRouter();

  static final Handler _homeHandler = Handler(
    handlerFunc: (context, params) => HomePage(),
  );

  static final Handler _selectRoute = Handler(
    handlerFunc: (context, params) => SelectRount(),
  );

  static void setupRouter() {
    router.define("/home", handler: _homeHandler);
    router.define("/busStop", handler: _selectRoute);




  }
}
