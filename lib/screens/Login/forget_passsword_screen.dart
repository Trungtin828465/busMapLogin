// import 'package:flutter/material.dart';
// import 'package:busmap/widgets/custom_scaffold.dart';
// import '../../theme/theme.dart';
// import 'reset_password_screen.dart'; // Import màn hình mới
//
// class ForgetPasswordScreen extends StatefulWidget {
//   const ForgetPasswordScreen({super.key});
//
//   @override
//   State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
// }
//
// class _ForgetPasswordScreenState extends State<ForgetPasswordScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _emailController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }
//
//   void _sendOtp() {
//     String email = _emailController.text.trim();
//     if (email.isNotEmpty) {
//       print('Gửi OTP đến: $email');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('OTP đã được gửi!')),
//       );
//       _tabController.animateTo(1);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng nhập email')),
//       );
//     }
//   }
//
//   void _verifyOtp() {
//     String email = _emailController.text.trim();
//     String otp = _otpController.text.trim();
//     if (email.isNotEmpty && otp.isNotEmpty) {
//       print('Xác nhận OTP: $otp cho $email');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Xác nhận OTP thành công!')),
//       );
//       // Chuyển sang ResetPasswordScreen với email
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ResetPasswordScreen(email: email),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng nhập đầy đủ email và OTP')),
//       );
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
//                       'Quên mật khẩu',
//                       style: TextStyle(
//                         fontSize: 30.0,
//                         fontWeight: FontWeight.w900,
//                         color: lightColorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 20.0),
//                     TabBar(
//                       controller: _tabController,
//                       labelColor: lightColorScheme.primary,
//                       unselectedLabelColor: Colors.black45,
//                       indicatorColor: lightColorScheme.primary,
//                       tabs: const [
//                         Tab(text: 'Gửi OTP'),
//                         Tab(text: 'Xác nhận OTP'),
//                       ],
//                     ),
//                     const SizedBox(height: 20.0),
//                     SizedBox(
//                       height: 400,
//                       child: TabBarView(
//                         controller: _tabController,
//                         children: [
//                           Column(
//                             children: [
//                               TextFormField(
//                                 controller: _emailController,
//                                 decoration: InputDecoration(
//                                   label: const Text('Email'),
//                                   hintText: 'Enter Email',
//                                   hintStyle: const TextStyle(color: Colors.black26),
//                                   border: OutlineInputBorder(
//                                     borderSide: const BorderSide(color: Colors.black12),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: const BorderSide(color: Colors.black12),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                                 keyboardType: TextInputType.emailAddress,
//                               ),
//                               const SizedBox(height: 25.0),
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: ElevatedButton(
//                                   onPressed: _sendOtp,
//                                   child: const Text('Gửi OTP'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Column(
//                             children: [
//                               TextFormField(
//                                 controller: _emailController,
//                                 decoration: InputDecoration(
//                                   label: const Text('Email'),
//                                   hintText: 'Enter Email',
//                                   hintStyle: const TextStyle(color: Colors.black26),
//                                   border: OutlineInputBorder(
//                                     borderSide: const BorderSide(color: Colors.black12),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: const BorderSide(color: Colors.black12),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                                 keyboardType: TextInputType.emailAddress,
//                               ),
//                               const SizedBox(height: 25.0),
//                               TextFormField(
//                                 controller: _otpController,
//                                 decoration: InputDecoration(
//                                   label: const Text('OTP'),
//                                   hintText: 'Enter OTP',
//                                   hintStyle: const TextStyle(color: Colors.black26),
//                                   border: OutlineInputBorder(
//                                     borderSide: const BorderSide(color: Colors.black12),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: const BorderSide(color: Colors.black12),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                                 keyboardType: TextInputType.number,
//                               ),
//                               const SizedBox(height: 25.0),
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: ElevatedButton(
//                                   onPressed: _verifyOtp,
//                                   child: const Text('Xác nhận'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
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
import 'reset_password_screen.dart';
import 'package:busmap/service/LoginService.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final ApiServiceLogin _apiService = ApiServiceLogin();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    String email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        String message = await _apiService.sendOtp(email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        _tabController.animateTo(1);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    String email = _emailController.text.trim();
    String otp = _otpController.text.trim();
    if (email.isNotEmpty && otp.isNotEmpty) {
      try {
        // Chuyển thẳng sang ResetPasswordScreen, không cần xác nhận OTP riêng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email, otp: otp),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ email và OTP')),
      );
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
                      'Quên mật khẩu',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: lightColorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TabBar(
                      controller: _tabController,
                      labelColor: lightColorScheme.primary,
                      unselectedLabelColor: Colors.black45,
                      indicatorColor: lightColorScheme.primary,
                      tabs: const [
                        Tab(text: 'Gửi OTP'),
                        Tab(text: 'Xác nhận OTP'),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  label: const Text('Email'),
                                  hintText: 'Enter Email',
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
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 25.0),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _sendOtp,
                                  child: const Text('Gửi OTP'),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  label: const Text('Email'),
                                  hintText: 'Enter Email',
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
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 25.0),
                              TextFormField(
                                controller: _otpController,
                                decoration: InputDecoration(
                                  label: const Text('OTP'),
                                  hintText: 'Enter OTP',
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
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 25.0),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _verifyOtp,
                                  child: const Text('Xác nhận'),
                                ),
                              ),
                            ],
                          ),
                        ],
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