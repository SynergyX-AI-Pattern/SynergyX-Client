import 'package:flutter/material.dart';
import 'package:stockapp/routes/TabView.dart';
import 'package:stockapp/screens/signup_screen.dart';
import 'package:stockapp/services/auth_service.dart';

/// 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _signupComplete = false;

  /// 로그인 처리 함수
  Future<void> _handleLogin() async {
    final success = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Tabview()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('로그인 실패')));
    }
  }

  /// 회원가입 화면으로 이동
  Future<void> _goToSignup() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
    if (result == true) {
      setState(() => _signupComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.image, size: 80), // 디자인용 이미지 자리
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '아이디',
                  hintText: '아이디를 입력해 주세요.',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력해 주세요.',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('로그인'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _goToSignup,
                  child: const Text('회원가입'),
                ),
              ),
              const Spacer(),
              if (_signupComplete)
                const Text(
                  '회원가입이 완료되었습니다',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}