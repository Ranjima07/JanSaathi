import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_providers.dart';
import '../../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _usePassword = false;
  bool _isOtpSent = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      bool success = false;

      if (_usePassword) {
        success = await authProvider.login(
          _mobileController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        if (!_isOtpSent) {
          await authProvider.sendOtp(_mobileController.text.trim());
          setState(() => _isOtpSent = true);
          _showMessage("OTP sent to your mobile");
          return;
        } else {
          success = await authProvider.verifyOtp(
            _mobileController.text.trim(),
            _otpController.text.trim(),
          );
        }
      }

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _showMessage("Authentication failed");
      }
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                /// Government Emblem
                Image.asset(
                  'assets/images/india_emblem.png',
                  height: 150,
                ),

                const SizedBox(height: 16),

                Text(
                  "JanSaathi",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E2A78),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Enter OTP sent to your mobile",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                _loginModeToggle(),

                const SizedBox(height: 30),

                _buildFields(),

                const SizedBox(height: 16),

                if (_isOtpSent && !_usePassword)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isOtpSent = false;
                          _otpController.clear();
                        });
                      },
                      child: const Text(
                        "Change Mobile Number",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2A78),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Text(
                            _usePassword
                                ? "Login"
                                : (_isOtpSent
                                    ? "Verify & Login"
                                    : "Get OTP"),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New Citizen? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        "Register Here",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Segmented Control
  Widget _loginModeToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleButton("Mobile OTP", !_usePassword, () {
            setState(() {
              _usePassword = false;
              _isOtpSent = false;
              _otpController.clear();
            });
          }),
          _toggleButton("Password", _usePassword, () {
            setState(() {
              _usePassword = true;
              _isOtpSent = false;
            });
          }),
        ],
      ),
    );
  }

  Widget _toggleButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1E2A78) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    if (_usePassword) {
      return Column(
        children: [
          _inputField(
            controller: _mobileController,
            label: "Mobile Number",
            icon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.length < 10 ? "Invalid mobile number" : null,
          ),
          const SizedBox(height: 16),
          _inputField(
            controller: _passwordController,
            label: "Password",
            icon: Icons.lock,
            obscure: true,
            validator: (v) =>
                v == null || v.length < 4 ? "Invalid password" : null,
          ),
        ],
      );
    }

    return Column(
      children: [
        _inputField(
          controller: _mobileController,
          label: "Mobile Number",
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
          enabled: !_isOtpSent,
          validator: (v) =>
              v == null || v.length < 10 ? "Invalid mobile number" : null,
        ),
        if (_isOtpSent) ...[
          const SizedBox(height: 16),
          _inputField(
            controller: _otpController,
            label: "Enter OTP",
            icon: Icons.password,
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.length < 6 ? "Invalid OTP" : null,
          ),
        ],
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
