import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

class ApiService {
  late final Dio _dio;
  String? _token;
  CancelToken? _uploadCancelToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle common errors
        if (error.response?.statusCode == 401) {
          // Token expired or invalid
          await clearToken();
        }
        return handler.next(error);
      },
    ));

    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Cancel ongoing upload
  void cancelUpload() {
    _uploadCancelToken?.cancel('Upload cancelled by user');
    _uploadCancelToken = null;
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register(String email, String password, String displayName) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      });
      final token = response.data['access_token'];
      await _saveToken(token);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['access_token'];
      await _saveToken(token);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
      await clearToken();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Media endpoints
  Future<Map<String, dynamic>> getPresignedUrl(
    String type,
    String mimeType,
    String fileName,
    int fileSize,
  ) async {
    try {
      final response = await _dio.post('/media/presign', data: {
        'type': type,
        'mimeType': mimeType,
        'fileName': fileName,
        'fileSize': fileSize,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> completeUpload(
    String mediaObjectId,
    int? width,
    int? height,
    String? sha256,
  ) async {
    try {
      final response = await _dio.post('/media/complete', data: {
        'mediaObjectId': mediaObjectId,
        'width': width,
        'height': height,
        'sha256': sha256,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file to presigned URL with progress callback
  Future<void> uploadToPresignedUrl(
    String presignedUrl,
    List<int> fileBytes,
    String contentType, {
    Function(double)? onProgress,
  }) async {
    try {
      _uploadCancelToken = CancelToken();

      final dio = Dio(BaseOptions(
        connectTimeout: AppConfig.uploadTimeout,
        receiveTimeout: AppConfig.uploadTimeout,
        sendTimeout: AppConfig.uploadTimeout,
      ));

      await dio.put(
        presignedUrl,
        data: fileBytes,
        options: Options(
          headers: {
            'Content-Type': contentType,
          },
          // Don't follow redirects for S3
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
        cancelToken: _uploadCancelToken,
      );

      _uploadCancelToken = null;
    } on DioException catch (e) {
      _uploadCancelToken = null;
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Upload cancelled');
      }
      throw _handleError(e);
    }
  }

  // Wardrobe endpoints
  Future<List<dynamic>> getWardrobeItems({
    String? category,
    String? color,
    List<String>? seasonTags,
  }) async {
    try {
      final response = await _dio.get('/wardrobe/items', queryParameters: {
        if (category != null) 'category': category,
        if (color != null) 'color': color,
        if (seasonTags != null) 'season_tags': seasonTags.join(','),
      });
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createWardrobeItem(String primaryPhotoId) async {
    try {
      final response = await _dio.post('/wardrobe/items', data: {
        'primaryPhotoId': primaryPhotoId,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getWardrobeItem(String id) async {
    try {
      final response = await _dio.get('/wardrobe/items/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateWardrobeItem(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/wardrobe/items/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteWardrobeItem(String id) async {
    try {
      await _dio.delete('/wardrobe/items/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Outfit session endpoints
  Future<Map<String, dynamic>> createOutfitSession(String outfitPhotoId, Map<String, dynamic> context) async {
    try {
      final response = await _dio.post('/outfits/sessions', data: {
        'outfitPhotoId': outfitPhotoId,
        'context': context,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOutfitSession(String sessionId) async {
    try {
      final response = await _dio.get('/outfits/sessions/$sessionId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOutfitFeedback(String sessionId) async {
    try {
      final response = await _dio.get('/outfits/sessions/$sessionId/feedback');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getOutfitRecommendations(String sessionId) async {
    try {
      final response = await _dio.get('/outfits/sessions/$sessionId/recommendations');
      return response.data['recommendations'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getOutfitSessions() async {
    try {
      final response = await _dio.get('/outfits/sessions');
      return response.data['sessions'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Saved outfits
  Future<List<dynamic>> getSavedOutfits() async {
    try {
      final response = await _dio.get('/saved-outfits');
      return response.data['outfits'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> saveOutfit(String name, List<String> items, List<String> occasionTags) async {
    try {
      final response = await _dio.post('/saved-outfits', data: {
        'name': name,
        'items': items,
        'occasion_tags': occasionTags,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Billing
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final response = await _dio.get('/billing/status');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyPurchase(String provider, String receipt) async {
    try {
      final response = await _dio.post('/billing/verify', data: {
        'provider': provider,
        'receipt': receipt,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to user-friendly messages
  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Could not connect to server. Please check your internet connection.';
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      switch (statusCode) {
        case 400:
          return data['message'] ?? 'Invalid request';
        case 401:
          return 'Authentication required. Please log in again.';
        case 403:
          return 'Access denied';
        case 404:
          return 'Resource not found';
        case 413:
          return 'File too large. Maximum size is ${(AppConfig.maxFileSize / (1024 * 1024)).toStringAsFixed(0)}MB';
        case 422:
          if (data is Map && data.containsKey('message')) {
            return data['message'];
          }
          return 'Validation failed. Please check your input.';
        case 429:
          return 'Too many requests. Please wait a moment and try again.';
        case 500:
        case 502:
        case 503:
          return 'Server error. Please try again later.';
        default:
          if (data is Map && data.containsKey('message')) {
            return data['message'];
          }
          return 'An error occurred. Please try again.';
      }
    }

    return 'Network error. Please check your connection.';
  }
}
