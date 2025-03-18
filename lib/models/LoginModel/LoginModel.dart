class LoginModel {

  final String email;
  final String password;

  LoginModel({
    required this.email,
    required this.password,
  });

  // Chuyển đổi dữ liệu thành JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'Password': password,
    };
  }

  // Kiểm tra dữ liệu đầu vào (Validate)
  String? validate() {

    if (email.isEmpty || !email.contains("@")) {
      return "Email không hợp lệ";
    }

    if (password.isEmpty || password.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự";
    }
    return null; // Nếu không có lỗi
  }
}
