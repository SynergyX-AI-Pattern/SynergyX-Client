import 'package:flutter/material.dart';
import 'package:stockapp/routes/TabView.dart';
import 'package:stockapp/screens/signup_screen.dart';
import 'package:stockapp/services/auth_service.dart';
import 'package:stockapp/models/auth_response.dart';
import 'package:stockapp/services/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _showErrors = false;
  String? _serverError;

  // FocusNode 선언
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool get _bothFilled =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() => _serverError = null));
    _passwordController.addListener(() => setState(() => _serverError = null));
    // 화면이 로드되었을 때 이메일 입력 필드에 포커스를 자동으로 맞춤
    Future.delayed(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1.4),
      ),
      errorMaxLines: 2,
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _showErrors = true;
      _serverError = null;
    });

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final LoginResponse res = await _authService.login(email, password);

    if (!mounted) return;

    if (res.isSuccess) {
      await AuthState.updateFromLogin(res, email);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Tabview()),
      );
    } else {
      setState(() {
        _serverError = res.message ?? '로그인에 실패했습니다';
      });
    }
  }

  Future<void> _goToSignup() async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
    if (!mounted) return;
    if (result == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final grayBtnColor = Colors.grey.shade400;
    final blackBtnColor = Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode:
                      _showErrors
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 46),
                      CircleAvatar(
                        radius: 42,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icon2.png',
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '패턴캐처',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      const Text(
                        '이메일',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration('이메일을 입력해 주세요.'),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return '이메일을 입력해 주세요.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        '비밀번호',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: true,
                        decoration: _fieldDecoration('비밀번호를 입력해 주세요.'),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return '비밀번호를 입력해 주세요.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _bothFilled ? blackBtnColor : grayBtnColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('로그인'),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _goToSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('회원가입'),
                        ),
                      ),

                      // 서버 에러 메시지
                      if (_serverError != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _serverError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
