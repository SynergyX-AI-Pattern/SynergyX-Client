import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../services/image_search_api_service.dart';
import '../models/image_search_result.dart';
import '../widgets/image_search/image_card.dart';
import '../widgets/image_search/error_card.dart';
import '../widgets/image_search/result_card.dart';
import '../widgets/image_search/loading_dialog.dart';

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  final _picker = ImagePicker();
  final _api = ImageSearchApiService();

  File? _selectedFile;
  bool _loading = false;
  String? _error;
  ImageSearchResult? _result;

  CancelToken? _cancelToken; // 업로드 취소용

  // ─ 권한
  Future<bool> _ensureCameraPermission() async {
    final st = await Permission.camera.status;
    if (st.isGranted) return true;
    final req = await Permission.camera.request();
    if (req.isGranted) return true;
    if (req.isPermanentlyDenied) await openAppSettings();
    return false;
  }

  Future<bool> _ensureGalleryPermission() async {
    final p = await Permission.photos.status;
    if (p.isGranted) return true;
    final rp = await Permission.photos.request();
    if (rp.isGranted) return true;
    final rs = await Permission.storage.request(); // 안드 12-
    if (rs.isGranted) return true;
    if (rp.isPermanentlyDenied || rs.isPermanentlyDenied)
      await openAppSettings();
    return false;
  }

  // ─ 선택
  Future<void> _pickCamera() async {
    if (!await _ensureCameraPermission()) return;
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2048,
    );
    if (x == null) return;
    setState(() {
      _selectedFile = File(x.path);
      _error = null;
      _result = null;
    });
    await _upload();
  }

  Future<void> _pickGallery() async {
    if (!await _ensureGalleryPermission()) return;
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
    );
    if (x == null) return;
    setState(() {
      _selectedFile = File(x.path);
      _error = null;
      _result = null;
    });
    await _upload();
  }

  // ─ 업로드 + 지연/취소 처리
  Future<void> _upload() async {
    final file = _selectedFile;
    if (file == null) return;

    final bytes = await file.length();
    if (bytes > 20 * 1024 * 1024) {
      setState(() {
        _error = '이미지 용량이 커요. 최대 20MB까지만 업로드할 수 있어요.';
        _result = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    _cancelToken = CancelToken();
    final stopwatch = Stopwatch()..start();

    showLoadingDialog(context, _cancelToken);

    // ─ 에러 메시지 매핑
    String _friendlyMessage(String? code, String? fallback) {
      switch (code) {
        case 'IMAGE_STOCK_NOT_FOUND':
        case 'STOCK_IMAGE404':
          return '이미지로 종목을 찾지 못했어요.';
        case 'IMAGE4001':
        case 'IMAGE_FILE_MISSING':
          return '업로드된 이미지가 없습니다. 다시 선택해 주세요.';
        case 'IMAGE4002':
        case 'IMAGE_FILE_TOO_LARGE':
          return '이미지 용량이 커요. 최대 20MB까지만 업로드할 수 있어요.';
        case 'IMAGE4003':
        case 'INVALID_IMAGE_FILE_TYPE':
          return '지원하지 않는 이미지 형식이에요. jpg, jpeg, png만 가능해요.';
        default:
          return fallback ?? '처리 중 문제가 발생했어요.\n잠시 후 다시 시도해 주세요.';
      }
    }

    try {
      final res = await _api.searchStockByImage(
        imageFile: file,
        bearerToken: null,
        cancelToken: _cancelToken!,
      );

      stopwatch.stop();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // 로딩 닫기

      if (stopwatch.elapsed.inSeconds >= 6 && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('잠시만요… 🙌 결과가 도착했어요!')));
      }

      if (res.isSuccess == true && res.result != null) {
        setState(() {
          _error = null;
          _result = res;
        });
      } else {
        final msg = _friendlyMessage(res.code, res.message);
        setState(() {
          _result = null;
          _error = msg;
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;

      if (CancelToken.isCancel(e)) {
        setState(() {
          _loading = false;
          _error = '요청이 취소되었습니다.';
        });
        return;
      }

      Navigator.of(context, rootNavigator: true).pop(); // 로딩 닫기

      String? codeFromBody;
      if (e.response?.data is Map) {
        final map = e.response!.data as Map;
        codeFromBody = (map['code'] ?? map['errorCode']) as String?;
      }
      final msg = _friendlyMessage(codeFromBody, e.message);

      setState(() {
        _error = '업로드 실패: $msg';
        _result = null;
      });
    } catch (e, st) {
      debugPrint('upload error: $e\n$st');
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // 로딩 닫기
      setState(() {
        _error = '업로드 실패: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─ 공통 버튼 스타일
  ButtonStyle get _moreButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2C2C2C),
    foregroundColor: const Color(0xFFF5F5F5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(vertical: 10),
  );

  // ─ 카메라/앨범 버튼
  Widget _buildPickButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: _moreButtonStyle,
            icon: const Icon(Icons.photo_camera, color: Color(0xFFF5F5F5)),
            label: const Text(
              '카메라',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: _loading ? null : _pickCamera,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: _moreButtonStyle,
            icon: const Icon(Icons.photo_library, color: Color(0xFFF5F5F5)),
            label: const Text(
              '앨범',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: _loading ? null : _pickGallery,
          ),
        ),
      ],
    );
  }

  // ─ 결과 카드 아래 재시도 버튼
  Widget _buildRetryButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: _moreButtonStyle,
            onPressed: _loading ? null : _pickCamera,
            icon: const Icon(Icons.photo_camera, color: Color(0xFFF5F5F5)),
            label: const Text(
              '다시 찍기',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: _moreButtonStyle,
            onPressed: _loading ? null : _pickGallery,
            icon: const Icon(Icons.photo_library, color: Color(0xFFF5F5F5)),
            label: const Text(
              '앨범에서 선택',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ─ UI
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'AI 종목검색',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ImageCard(file: _selectedFile),
              const SizedBox(height: 12),

              // ─ 결과 없는 경우에만 카메라/앨범 버튼
              if (_result == null && _error == null) _buildPickButtons(),

              // ─ 에러 카드 (내부에 재시도 버튼 포함)
              if (_error != null)
                ErrorCard(
                  error: _error!,
                  onRetryCamera: _pickCamera,
                  onRetryGallery: _pickGallery,
                  loading: _loading,
                  buttonStyle: _moreButtonStyle,
                ),

              // ─ 결과 카드 + 결과 카드 하단 버튼
              if (_result != null && _result!.result != null) ...[
                const SizedBox(height: 10),
                ResultCard(
                  result: _result!.result!,
                  buttonStyle: _moreButtonStyle,
                  loading: _loading,
                  onRetryCamera: _pickCamera,
                  onRetryGallery: _pickGallery,
                ),
                const SizedBox(height: 18),
                _buildRetryButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
