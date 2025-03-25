class BusRoute {
  final String routeId;
  final String routeName;

  BusRoute({required this.routeId, required this.routeName});

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      routeId: json['RouteId'].toString(),
      routeName: json['RouteName'].toString(),
    );
  }
}