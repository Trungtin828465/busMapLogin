import 'dart:ffi';

class BusRouteDetail {
  final String routeId;    // id xe
  final String routeNo;   // mã tuyến xe
  final String numOfSeats; // số chỗ ngồi
  final String routeName;  // tên xe chạy từ a -> b
  final String inboundDescription; // DS điểm đầu
  final String outboundDescription; // DS điểm cuối
  final String inBoundName; // điểm đầu
  final String outBoundName; // điểm cuối
  final String routerName; // tên xe bus
  final String tickets; // gias
  final String operationTime; // thoi gian hoạt động
  final String totalTrip; // tong chuyến đi
  final double  distance; //quang duong
  BusRouteDetail({
    required this.routeId,
    required this.routeNo,
    required this.numOfSeats,
    required this.routeName,
    required this.inboundDescription,
    required this.outboundDescription,
    required this.operationTime,
    required this.inBoundName,
    required this.outBoundName,
    required this.routerName,
    required this.tickets,
    required this.distance,
    required this.totalTrip,
  });

  factory BusRouteDetail.fromJson(Map<String, dynamic> json) {
    return BusRouteDetail(
      routeId: json['RouteId'].toString(),
      routeNo: json['RouteNo'].toString(),
      numOfSeats: json['NumOfSeats'].toString(),
      routeName: json['RouteName'].toString(),
      inboundDescription: json['InBoundDescription'] ?? 'Không có dữ liệu',
      outboundDescription: json['OutBoundDescription'] ?? 'Không có dữ liệu',
      inBoundName: json['InBoundName'] ?? 'Không có dữ liệu',
      outBoundName: json['OutBoundName'] ?? 'Không có dữ liệu',
      routerName: json['RouteName'] ?? 'Không có dữ liệu',
      tickets: json['Tickets'] ?? 'Không có dữ liệu',
      operationTime: json['OperationTime'] ?? 'Không có dữ liệu',
      distance: json['Distance'] is num ? json['Distance'] : double.tryParse(json['Distance'].toString()) ?? 0.0,
      totalTrip: json['TotalTrip'] ?? 'Không có dữ liệu',


    );
  }
}