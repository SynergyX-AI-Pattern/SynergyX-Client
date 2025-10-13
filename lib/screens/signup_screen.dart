import 'package:flutter/material.dart';
import 'package:stockapp/services/auth_service.dart';
import 'package:stockapp/models/auth_response.dart';

/// 회원가입 화면
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _authService = AuthService();
  bool _isSubmitting = false;
  bool _marketingAgree = false; // 마케팅 활용 동의 여부
  bool _eventAgree = false; // 이벤트 알림 수신 여부
  String? _emailError; // 이메일 입력 오류 메시지
  String? _passwordError; // 비밀번호 입력 오류 메시지
  String? _confirmError; // 비밀번호 확인 입력 오류 메시지

  /// 이메일 형식 검증 함수
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return '이메일을 입력해 주세요.';
    }
    final hasAtSymbol = value.contains('@');
    final hasDomain = value.contains('.');
    if (!(hasAtSymbol && hasDomain)) {
      return '올바른 이메일 형식을 입력해 주세요.';
    }
    return null;
  }

  /// 비밀번호 조건 검증 함수
  String? _validatePassword(String value) {
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다.';
    }
    final hasLetter = value.contains(RegExp('[A-Za-z]'));
    final hasNumber = value.contains(RegExp('[0-9]'));
    if (!(hasLetter && hasNumber)) {
      return '영어와 숫자를 모두 포함해야 합니다.';
    }
    return null;
  }

  /// 비밀번호 확인 검증 함수
  String? _validateConfirmPassword(String password, String confirm) {
    if (confirm.isEmpty) {
      return '비밀번호 확인을 입력해 주세요.';
    }
    if (password != confirm) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return null;
  }

  /// 회원가입 처리 함수
  Future<void> _handleSignup() async {
    // 입력값에 대한 검증을 먼저 수행하여 오류 메시지를 표시
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);
    final confirmError =
    _validateConfirmPassword(_passwordController.text, _confirmController.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmError = confirmError;
    });

    if (emailError != null || passwordError != null || confirmError != null) {
      return;
    }
    setState(() => _isSubmitting = true);

    final SimpleResponse res = await _authService.signup(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      _marketingAgree,
      _eventAgree,
    );

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (res.isSuccess) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? '회원가입에 실패했습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '이름을 입력해 주세요.',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '아이디',
                  hintText: '이메일을 입력해 주세요.',
                  helperText: '이메일을 입력하세요.',
                  errorText: _emailError,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '영어, 숫자를 포함한 8~20자리를 입력해 주세요.',
                  helperText: '패스워드는 8글자 이상 입력해 주세요.',
                  errorText: _passwordError,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  hintText: '비밀번호를 입력해 주세요.',
                  errorText: _confirmError,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              // 이용 약관 동의 체크박스들
              CheckboxListTile(
                value: _marketingAgree,
                onChanged: (v) => setState(() => _marketingAgree = v ?? false),
                title: const Text('마케팅 정보 수신 동의'),
              ),
              CheckboxListTile(
                value: _eventAgree,
                onChanged: (v) => setState(() => _eventAgree = v ?? false),
                title: const Text('이벤트 알림 수신 동의'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSignup,
                  child: const Text('가입하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}