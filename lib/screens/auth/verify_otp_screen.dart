// lib/screens/auth/verify_otp_screen.dart
import 'package:AirVibe/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AirVibe/services/auth_service.dart';

class VerifyOTPScreen extends ConsumerStatefulWidget {
  final String email;
  final bool fromRegister;
  
  const VerifyOTPScreen({
    super.key,
    required this.email,
    this.fromRegister = false,
  });

  @override
  ConsumerState<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends ConsumerState<VerifyOTPScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6, 
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6, 
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }
  }

  void _onOtpBackspace(int index) {
    if (_otpControllers[index].text.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpCode;
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ mã OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.verifySignUp(
        email: widget.email,
        otp: otp,
      );

      // Debug: Log kết quả verify
      print('🔐 Verify OTP result: $result');

      if (mounted) {
        if (result['success']) {
          // Debug: Check token sau khi verify
          final token = await AuthService.getToken();
          print('💾 Token after verify: ${token != null}');
          if (token != null) {
            print('🔑 Token preview: ${token.substring(0, 30)}...');
          }

          // Xác thực thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Xác thực thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          
          if (widget.fromRegister) {
            // Từ đăng ký → chuyển đến home
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          } else {
            // Từ forgot password → quay lại login
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } else {
          // Xác thực thất bại
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Mã OTP không đúng'),
              backgroundColor: Colors.red,
            ),
          );
          
          // Clear OTP fields
          for (var controller in _otpControllers) {
            controller.clear();
          }
          _otpFocusNodes[0].requestFocus();
        }
      }
    } catch (e) {
      print('❌ Verify OTP error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi không mong đợi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    try {
      final result = await AuthService.resendOTP(
        email: widget.email,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Mã OTP mới đã được gửi!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear current OTP
          for (var controller in _otpControllers) {
            controller.clear();
          }
          _otpFocusNodes[0].requestFocus();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gửi lại OTP thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi lại OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Blue-900
              Color(0xFF3B82F6), // Blue-500
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  onPressed: (_isLoading || _isResending) ? null : () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back, 
                    color: Colors.white.withOpacity((_isLoading || _isResending) ? 0.4 : 1.0),
                  ),
                ),

                const SizedBox(height: 40),

                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Nhập mã 6 số',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nhập mã 6 số được gửi về email\n${widget.email}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      height: 55,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        enabled: !_isLoading && !_isResending,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onOtpChanged(value, index),
                        onTap: () {
                          _otpControllers[index].selection = TextSelection.fromPosition(
                            TextPosition(offset: _otpControllers[index].text.length),
                          );
                        },
                        onEditingComplete: () {
                          if (_otpCode.length == 6) {
                            _verifyOTP();
                          }
                        },
                        onFieldSubmitted: (value) {
                          if (value.isEmpty) {
                            _onOtpBackspace(index);
                          }
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                // Resend OTP
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Email không nhận được?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: (_isLoading || _isResending) ? null : _resendOTP,
                        child: _isResending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: LoadingWidget(),
                              )
                            : Text(
                                'Gửi lại mã',
                                style: TextStyle(
                                  color: Colors.white.withOpacity((_isLoading || _isResending) ? 0.4 : 1.0),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white.withOpacity((_isLoading || _isResending) ? 0.4 : 1.0),
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _isResending) ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      disabledBackgroundColor: Colors.white.withOpacity(0.7),
                      disabledForegroundColor: const Color(0xFF1E3A8A).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: LoadingWidget(),
                          )
                        : const Text(
                            'Tiếp tục',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Auto-verify hint
                if (_otpCode.length == 6 && !_isLoading && !_isResending)
                  Center(
                    child: Text(
                      'Nhấn "Tiếp tục" để xác thực',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}