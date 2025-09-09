import 'package:flutter/material.dart';
import 'package:stockapp/routes/TabView.dart';
import 'package:stockapp/screens/signup_screen.dart';
import 'package:stockapp/services/auth_service.dart';

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

  bool _showErrors = false;        // 버튼 클릭 후 에러 노출 트리거
  String? _serverError;            // 서버 로그인 실패 메시지

  bool get _bothFilled =>
      _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // 입력 변화에 따라 버튼 색/서버 에러 초기화
    _emailController.addListener(() => setState(() => _serverError = null));
    _passwordController.addListener(() => setState(() => _serverError = null));
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
    // 에러 보여주기 시작
    setState(() {
      _showErrors = true;
      _serverError = null;
    });

    // 폼 검증(미입력 시 빨간 문구 노출)
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final success = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Tabview()),
      );
    } else {
      // 서버 로그인 실패 메시지
      setState(() {
        _serverError = '존재하지 않는 아이디거나 옳지 않은 패스워드 입니다.';
      });
    }
  }

  Future<void> _goToSignup() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
    if (!mounted) return;
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final grayBtnColor = Colors.grey.shade400;
    final blackBtnColor = Colors.black;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                autovalidateMode: _showErrors
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 36),
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 52, color: Colors.black54),
                    ),
                    const SizedBox(height: 36),

                    const Text('아이디',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration('아이디를 입력해 주세요.'),
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) {
                          return '아이디를 입력해 주세요.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text('비밀번호',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
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

                    // 로그인 버튼: 입력 모두 있으면 검정, 아니면 회색
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleLogin, // 비어있어도 눌려서 에러 노출
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

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
