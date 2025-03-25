import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:busmap/models/LoginModel/RegisterModel.dart';
import 'package:busmap/models/LoginModel/LoginModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:busmap/models/BusStopModel/BusStopModel.dart';
import 'dart:io';

class ApiService {
  final String baseUrl = "https://10.0.2.2:7222/api/busstops"; // Đổi cổng đúng với API


  Future<List<BusStopModel>> fetchBusStops() async {
  try {
  final response = await http.get(Uri.parse('$baseUrl/TinBusStop'));

  print("📡 Đang gọi API: $baseUrl/TinBusStop");
  print("🔄 Status Code API: ${response.statusCode}");
  print("📦 Response Body API: ${response.body}");

  if (response.statusCode == 200) {
  final List<dynamic> data = json.decode(response.body);
  List<BusStopModel> busStops =
  data.map((json) => BusStopModel.fromJson(json)).toList();
  print("✅ Số lượng điểm dừng nhận được: ${busStops.length}");
  return busStops;
  } else {
  print("⚠️ API trả về lỗi: ${response.body}");
  throw Exception("Lỗi từ API: ${response.body}");
  }
  } catch (e) {
  print("❌ Lỗi không xác định: $e");
  throw Exception(e.toString());
  }
  }


  // Tin
  // Đăng nhập
  Future<String> login(LoginModel loginModel) async {
    String? validateError = loginModel.validate();
    if (validateError != null) {
      throw Exception(validateError);
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginModel.toJson()),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        String userEmail = data['account']['email'] ?? ''; // 🔹 Lấy đúng đường dẫn

        // Lưu email vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', userEmail);

        return "Đăng nhập thành công. Email: $userEmail";
      } else {
        String errorMessage = data.containsKey('message') ? data['message'] : 'Lỗi đăng nhập không xác định';
        throw Exception(errorMessage);
      }
    } on SocketException {
      print("Lỗi kết nối mạng");
      throw Exception("Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.");
    } on FormatException {
      print("Lỗi định dạng JSON");
      throw Exception("Dữ liệu phản hồi không đúng định dạng.");
    } catch (e) {
      print("Lỗi không xác định: $e");
      throw Exception(e.toString());
    }
  }

  // Đăng ký
  Future<String> register(RegisterModel registerModel) async {
    String? validationError = registerModel.validate();
    if (validationError != null) {
      throw Exception(validationError);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registerModel.toJson()),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Đăng ký thành công';
      } else {
        // Nếu API trả về lỗi có chứa 'message', lấy thông báo đó
        String errorMessage = data.containsKey('message')
            ? data['message']
            : 'Lỗi đăng ký không xác định';

        throw Exception(errorMessage);
      }
    } on SocketException {
      print("Lỗi kết nối mạng");
      throw Exception("Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.");
    } on FormatException {
      print("Lỗi định dạng JSON");
      throw Exception("Dữ liệu phản hồi không đúng định dạng.");
    } catch (e) {
      print("Lỗi không xác định: $e");
      throw Exception(e.toString()); // lỗi api
    }
  }




  // Gửi OTP
  Future<Map<String, dynamic>> sendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Send-OTP'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': email}),
    );
    return _handleResponse(response);
  }

  // Đổi mật khẩu sau khi nhập OTP
  Future<Map<String, dynamic>> changePassword(String email, String otp, String newPassword, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ChangePassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Email': email,
        'OTP': otp,
        'NewPassword': newPassword,
        'ConfirmPassword': confirmPassword
      }),
    );
    return _handleResponse(response);
  }

// XG
  // Xử lý phản hồi chung
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['message'] ?? 'Lỗi không xác định');
    }
  }
}