// import 'package:flutter/material.dart';
// import 'package:busmap/widgets/custom_scaffold.dart';
// import '../../theme/theme.dart';
//
// class ResetPasswordScreen extends StatefulWidget {
//   final String email;
//
//   const ResetPasswordScreen({super.key, required this.email});
//
//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }
//
// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//
//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   // Hàm reset mật khẩu (giả lập, thay bằng API thật nếu có)
//   void _resetPassword() {
//     String newPassword = _newPasswordController.text.trim();
//     String confirmPassword = _confirmPasswordController.text.trim();
//
//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng nhập đầy đủ mật khẩu')),
//       );
//     } else if (newPassword != confirmPassword) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
//       );
//     } else {
//       print('Reset mật khẩu cho ${widget.email} với mật khẩu mới: $newPassword');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Đặt lại mật khẩu thành công!')),
//       );
//       // Quay lại màn hình đăng nhập
//       Navigator.popUntil(context, (route) => route.isFirst);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomScaffold(
//       child: Column(
//         children: [
//           const Expanded(flex: 1, child: SizedBox(height: 10)),
//           Expanded(
//             flex: 7,
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(40.0),
//                   topRight: Radius.circular(40.0),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Đặt lại mật khẩu',
//                       style: TextStyle(
//                         fontSize: 30.0,
//                         fontWeight: FontWeight.w900,
//                         color: lightColorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 40.0),
//                     TextFormField(
//                       controller: _newPasswordController,
//                       obscureText: true,
//                       obscuringCharacter: '*',
//                       decoration: InputDecoration(
//                         label: const Text('Mật khẩu mới'),
//                         hintText: 'Enter New Password',
//                         hintStyle: const TextStyle(color: Colors.black26),
//                         border: OutlineInputBorder(
//                           borderSide: const BorderSide(color: Colors.black12),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: Colors.black12),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25.0),
//                     TextFormField(
//                       controller: _confirmPasswordController,
//                       obscureText: true,
//                       obscuringCharacter: '*',
//                       decoration: InputDecoration(
//                         label: const Text('Xác nhận mật khẩu'),
//                         hintText: 'Confirm New Password',
//                         hintStyle: const TextStyle(color: Colors.black26),
//                         border: OutlineInputBorder(
//                           borderSide: const BorderSide(color: Colors.black12),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: Colors.black12),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25.0),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _resetPassword,
//                         child: const Text('Xác nhận'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:busmap/widgets/custom_scaffold.dart';
import '../../theme/theme.dart';
import 'package:busmap/service/LoginService.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp; // Thêm OTP từ ForgetPasswordScreen

  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiServiceLogin _apiService = ApiServiceLogin();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ mật khẩu')),
      );
    } else if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
    } else {
      try {
        String message = await _apiService.changePassword(
          widget.email,
          widget.otp,
          newPassword,
          confirmPassword,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Đặt lại mật khẩu',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: lightColorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                        label: const Text('Mật khẩu mới'),
                        hintText: 'Enter New Password',
                        hintStyle: const TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                        label: const Text('Xác nhận mật khẩu'),
                        hintText: 'Confirm New Password',
                        hintStyle: const TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _resetPassword,
                        child: const Text('Xác nhận'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}