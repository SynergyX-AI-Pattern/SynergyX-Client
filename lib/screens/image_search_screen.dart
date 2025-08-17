import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../services/image_search_api_service.dart';
import '../models/image_search_result.dart';
import 'stock_detail_screen.dart'; // DetailScreen
import '../models/StockItemModel.dart'; // StockItem (필드: stockId, price, changeRate, rank, name, imageUrl)

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
    await _upload(autoNavigate: false); // 자동 이동 제거
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
    await _upload(autoNavigate: false); // 자동 이동 제거
  }

  // ─ 업로드 + 지연/취소 처리
  Future<void> _upload({bool autoNavigate = false}) async {
    final file = _selectedFile;
    if (file == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    _cancelToken = CancelToken();
    final stopwatch = Stopwatch()..start();

    // 취소 가능한 로딩 다이얼로그
    _showCancellableLoading();

    try {
      final res = await _api.searchStockByImage(
        imageFile: file,
        bearerToken: null, // 필요시 토큰 넣기
        cancelToken: _cancelToken!, // ← 취소 토큰
      );

      stopwatch.stop();

      if (!mounted) return;
      setState(() => _result = res);

      if (mounted) Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      // 8초 이상 걸렸으면 사용자 안내
      if (stopwatch.elapsed.inSeconds >= 8 && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('잠시만요… 🙌 결과가 도착했어요!')));
      }

      // 자동 이동 x
    } on DioException catch (e) {
      if (!mounted) return;
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      if (CancelToken.isCancel(e)) {
        setState(() {
          _loading = false;
          _error = '요청이 취소되었습니다.';
        });
        return;
      }
      setState(() {
        _error = '업로드 실패(Dio): ${e.message}';
      });
    } catch (e, st) {
      debugPrint('upload error: $e\n$st');
      if (!mounted) return;
      Navigator.of(context).pop(); // 로딩 닫기
      setState(() {
        _error = '업로드 실패: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showCancellableLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Row(
              children: const [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
                SizedBox(width: 16),
                Expanded(child: Text('이미지 업로드 중...')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _cancelToken?.cancel('사용자 취소');
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                child: const Text('취소'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─ UI
  @override
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // 상태바 배경
        statusBarIconBrightness: Brightness.dark, // 안드로이드 아이콘 색
        statusBarBrightness: Brightness.light, // iOS 아이콘 색
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          // 앱바 배경
          surfaceTintColor: const Color(0xFFFFFFFF),
          // M3 표면 틴트 제거
          elevation: 0,
          titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          title: const Text('AI 종목검색'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_selectedFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedFile!,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: const Text('이미지를 선택하세요.'),
                ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('카메라'),
                      onPressed: _loading ? null : _pickCamera,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('앨범'),
                      onPressed: _loading ? null : _pickGallery,
                    ),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],

              if (_result != null) ...[
                const Divider(height: 24),
                const Text(
                  'AI 분석으로 찾은 종목',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (_result!.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _result!.imageUrl!,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(_result!.name ?? '종목명 미확인'),
                const SizedBox(height: 12),
                if (_result!.id != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('종목 상세 보기'),
                    onPressed: () {
                      final r = _result!;
                      final item = StockItem(
                        stockId: r.id!,
                        name: r.name ?? '',
                        imageUrl: r.imageUrl ?? '',
                        price: 0,
                        changeRate: 0,
                        rank: 0,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(stock: item),
                        ),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
