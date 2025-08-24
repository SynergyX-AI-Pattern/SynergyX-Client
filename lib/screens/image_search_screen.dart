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
  bool _isDialogOpen = false; // 로딩 다이얼로그 열린 상태 추적

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

    // 20MB 초과 시 업로드 하지 않고 즉시 안내
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

    // 취소 가능한 로딩 다이얼로그
    _showCancellableLoading();

    // - 에러 메시지 매핑
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
        bearerToken: null, // 필요시 토큰 넣기
        cancelToken: _cancelToken!, // ← 취소 토큰
      );

      stopwatch.stop();

      if (!mounted) return;
      setState(() => _result = res);

      _closeLoadingIfOpen(); // 로딩 다이얼로그 닫기

      // 8초 이상 걸렸으면 사용자 안내
      if (stopwatch.elapsed.inSeconds >= 8 && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('잠시만요… 🙌 결과가 도착했어요!')));
      }

      // 비즈니스 성공/실패 분기
      if (res.isSuccess == true && res.id != null) {
        // 성공: 결과 카드 표시 (자동 이동은 여기서 선택적으로)
        setState(() {
          _error = null;
          _result = res;
        });

        // 자동 이동 시 주석 해제
        // if (autoNavigate) {
        //   final item = StockItem(
        //     stockId: res.id!, name: res.name ?? '', imageUrl: res.imageUrl ?? '',
        //     price: 0, changeRate: 0, rank: 0,
        //   );
        //   await Navigator.of(context).push(
        //     MaterialPageRoute(builder: (_) => DetailScreen(stock: item)),
        //   );
        // }
      } else {
        // 실패: 코드 기반 에러 메시지 노출, 결과 카드 숨김
        final msg = _friendlyMessage(res.code, res.message);
        setState(() {
          _result = null;
          _error = msg;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } on DioException catch (e) {
      if (!mounted) return;
      // 로딩 다이얼로그 닫기
      _closeLoadingIfOpen();

      if (CancelToken.isCancel(e)) {
        setState(() {
          _loading = false;
          _error = '요청이 취소되었습니다.';
        });
        return;
      }

      // 서비스 레벨에서 4xx를 응답으로 돌리지 않는 환경 대비: 404/400도 에러 메시지 매핑
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
      _closeLoadingIfOpen(); // 로딩 닫기
      setState(() {
        _error = '업로드 실패: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showCancellableLoading() {
    _isDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
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
                  _isDialogOpen = false;
                  Navigator.of(dialogCtx).pop(); // 다이얼로그 닫기
                },
                child: const Text('취소'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _isDialogOpen = false; // 어떤 경로로든 닫히면 false 보장
    });
  }

  void _closeLoadingIfOpen() {
    if (_isDialogOpen && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    _isDialogOpen = false;
  }

  // ─ 공통 버튼 스타일
  ButtonStyle get _moreButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2C2C2C), // 다크그레이
    foregroundColor: const Color(0xFFF5F5F5), // 오프화이트
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(vertical: 10),
  );

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
              // ─ 이미지 영역 (TopStockListCard 스타일)
              if (_selectedFile != null)
                Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedFile!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1,
                  child: Container(
                    height: 180,
                    alignment: Alignment.center,
                    child: const Text(
                      '이미지를 선택해주세요.',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // ─ 카메라/앨범 버튼 (공통 스타일 적용)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: _moreButtonStyle,
                      icon: const Icon(
                        Icons.photo_camera,
                        color: Color(0xFFF5F5F5),
                      ),
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
                      icon: const Icon(
                        Icons.photo_library,
                        color: Color(0xFFF5F5F5),
                      ),
                      label: const Text(
                        '앨범',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: _loading ? null : _pickGallery,
                    ),
                  ),
                ],
              ),

              // ─ 에러 영역 (버튼 포함)
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_error!.contains('용량'))
                        const Text('• 이미지 크기를 줄이거나 스크린샷 대신 원본 이미지를 사용해 보세요.'),
                      if (_error!.contains('형식'))
                        const Text('• 파일 확장자가 jpg/jpeg/png인지 확인하세요.'),
                      if (_error!.contains('찾지 못했어요'))
                        const Text('• 선명하게 다시 촬영해 보세요.'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: _moreButtonStyle,
                              onPressed: _loading ? null : _pickCamera,
                              icon: const Icon(
                                Icons.photo_camera,
                                color: Color(0xFFF5F5F5),
                              ),
                              label: const Text(
                                '다시 찍기',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: _moreButtonStyle,
                              onPressed: _loading ? null : _pickGallery,
                              icon: const Icon(
                                Icons.photo_library,
                                color: Color(0xFFF5F5F5),
                              ),
                              label: const Text(
                                '다른 이미지',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // ─ 결과 영역
              if (_result != null) ...[
                const Divider(height: 32),
                const Text(
                  'AI 분석으로 찾은 종목',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                if (_result!.imageUrl != null)
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage:
                                _result!.imageUrl != null
                                    ? NetworkImage(_result!.imageUrl!)
                                    : null,
                            child:
                                _result!.imageUrl == null
                                    ? const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _result!.name ?? '종목명 미확인',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_result!.id != null)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: _moreButtonStyle.copyWith(
                                  backgroundColor: MaterialStateProperty.all(
                                    const Color(0xFF1A237E),
                                  ),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.open_in_new,
                                  color: Color(0xFFF5F5F5),
                                ),
                                label: const Text(
                                  '종목 상세 보기',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
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
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
