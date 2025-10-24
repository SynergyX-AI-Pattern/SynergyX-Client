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

  @override
  void dispose() {
    // 화면이 사라질 때 컨트롤러를 정리하여 메모리 누수를 방지
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

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
      // 전체 배경을 흰색으로 맞춰 시안과 동일한 느낌을 제공
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          '회원가입',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabeledField(
                label: '이름',
                hint: '이름을 입력해 주세요.',
                controller: _nameController,
                onChanged: (_) => setState(() {}),
              ),
              _buildLabeledField(
                label: '아이디',
                hint: '이메일을 입력해 주세요.',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                onChanged: (_) => setState(() => _emailError = null),
              ),
              _buildLabeledField(
                label: '비밀번호',
                hint: '영어, 숫자를 포함한 8~20자리를 입력해 주세요.',
                controller: _passwordController,
                obscureText: true,
                errorText: _passwordError,
                onChanged: (_) => setState(() => _passwordError = null),
              ),
              _buildLabeledField(
                label: '비밀번호 확인',
                hint: '비밀번호를 다시 입력해 주세요.',
                controller: _confirmController,
                obscureText: true,
                errorText: _confirmError,
                onChanged: (_) => setState(() => _confirmError = null),
              ),
              const SizedBox(height: 12),
              _AgreementTile(
                title: '마케팅 정보 수신 동의',
                description: '새로운 소식과 혜택을 가장 먼저 받아보세요.',
                value: _marketingAgree,
                onChanged: (v) => setState(() => _marketingAgree = v),
              ),
              const SizedBox(height: 12),
              _AgreementTile(
                title: '이벤트 알림 수신 동의',
                description: '이벤트와 알림을 놓치지 않고 확인할 수 있어요.',
                value: _eventAgree,
                onChanged: (v) => setState(() => _eventAgree = v),
              ),
              const SizedBox(height: 28),
              // 가입하기 버튼: 라운드 처리된 프라이머리 버튼으로 강조
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _handleSignup,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF17191E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('가입하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 디자인 가이드를 반영한 입력 필드 생성 함수
  Widget _buildLabeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    bool obscureText = false,
    String? errorText,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 각 입력 필드의 타이틀을 시안과 유사하게 강조 표시
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: errorText != null ? const Color(0xFFFF8080) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFB7BAC6),
                ),
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              errorText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFFF5858),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 약관 동의 영역에 사용되는 커스텀 위젯
class _AgreementTile extends StatelessWidget {
  const _AgreementTile({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E5EC)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D30314A),
              offset: Offset(0, 10),
              blurRadius: 22,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3B5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              side: const BorderSide(color: Color(0xFFB9BED1), width: 1.5),
              activeColor: const Color(0xFF5A36C6),
            ),
          ],
        ),
      ),
    );
  }
}