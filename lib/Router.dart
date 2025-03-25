import 'package:busmap/screens/RouterBusStop/DetailBus.dart';
import 'package:busmap/screens/RouterBusStop/MapGpsSearch.dart';
import 'package:fluro/fluro.dart';  // Import Fluro
import 'package:busmap/screens/HomePage.dart';
import 'package:busmap/screens/RouterBusStop/SelectRoute.dart';
class FluroRouterConfig {
  static final FluroRouter router = FluroRouter();

  static final Handler _homeHandler = Handler(
    handlerFunc: (context, params) => HomePage(),
  );

  static final Handler _selectRoute = Handler(
    handlerFunc: (context, params) => SelectRount(),
  );
  static final Handler _mapSearch = Handler(
    handlerFunc: (context, params) => MapGpsSearch(),
  );
  static final Handler _busDetailHandler = Handler(
    handlerFunc: (context, params) {
      final routeId = params['routeId']?.first;  // Lấy routeId từ URL
      return BusDetailScreen(routeId: routeId ?? '');
    },
  );
  static void setupRouter() {
    router.define("/home", handler: _homeHandler);
    router.define("/selectRouter", handler: _selectRoute);
    router.define("/mapSearch", handler: _mapSearch);
    router.define("/busDetail/:routeId", handler: _busDetailHandler);  // 🔥 Thêm router mới

  }
}
