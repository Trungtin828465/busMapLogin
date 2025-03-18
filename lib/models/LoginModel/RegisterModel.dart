class RegisterModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  RegisterModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  // Chuyển đổi dữ liệu thành JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      'Fullname': fullName,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'Password': password,
    };
  }

  // Kiểm tra dữ liệu đầu vào (Validate)
  String? validate() {
    if (fullName.isEmpty) {
      return "Họ và tên không được để trống";
    }
    if (email.isEmpty || !email.contains("@")) {
      return "Email không hợp lệ";
    }
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      return "Số điện thoại phải có ít nhất 10 số";
    }
    if (password.isEmpty || password.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự";
    }
    return null; // Nếu không có lỗi
  }
}
